import os
import Network

// MARK: - NetworkConnectivityDelegate Protocol

public protocol NetworkConnectivityDelegate: class {

    func networkStatusChanged(online: Bool, connectivityStatus: String, msg: String)

}

// MARK: - NetworkConnectivity

/// Class identifer for `NetworkConnectivity`.
public class NetworkConnectivity {

    // MARK: - Static Constants

//    public static let shared = NetworkConnectivity()
    var host: NWEndpoint.Host
    var port: NWEndpoint.Port
    let queue: DispatchQueue = DispatchQueue(label: "Client Connection")
    var recvMsg: String = ""
    var nonstop: Bool
    var didRecv: Bool = false
    
    init(host: String, port: Int){
        self.host = NWEndpoint.Host(host)
        self.port = NWEndpoint.Port(rawValue: UInt16(port))!
        self.nonstop = true
    }

    // MARK: - Variables And Properties
    
    private var online: Bool = false
    private var tcpStreamAlive: Bool = false

    // MARK: - Variables And Properties

    public weak var networkStatusDelegate: NetworkConnectivityDelegate?


    // MARK: - Public Methods

    public func setup() {

        if self.tcpStreamAlive {
            print("TCP Stream is already setup.")
        }
        self.nonstop = true
        setupNWConnection()
    }

    public func stop() {
        self.nonstop = false
        self.tcpStreamAlive = false
    }
    
    public func updateAddress(host: String, port: Int) {
        self.host = NWEndpoint.Host(host)
        self.port = NWEndpoint.Port(rawValue: UInt16(port))!
        print(host)
    }
    
    //
    // MARK: - Private Methods

    private func setupNWConnection() {
        if self.nonstop {
//            print("Setting up nwConnection")
            
            let nwConnection = NWConnection(host: self.host, port: self.port, using: .tcp)
            nwConnection.stateUpdateHandler = self.stateDidChange(to:)
            self.setupReceive(on: nwConnection)
            nwConnection.start(queue: self.queue)
        } else {
//            print("Connection is stopped, press connect button again to reconnect to the server.")
        }
    }

    private func stateDidChange(to state: NWConnection.State) {
        switch state {
        case .setup:
            self.notifyDelegateOnChange(newStatusFlag: false, connectivityStatus: "setup")
            self.tcpStreamAlive = true
            break
        case .waiting:
            self.notifyDelegateOnChange(newStatusFlag: false, connectivityStatus: "waiting")
            self.tcpStreamAlive = true
            break
        case .ready:
            self.notifyDelegateOnChange(newStatusFlag: true, connectivityStatus: "ready")
            self.tcpStreamAlive = true
            break
        case .failed(let error):
            let errorMessage = "Error: \(error.localizedDescription)"
            self.notifyDelegateOnChange(newStatusFlag: false, connectivityStatus: errorMessage)
            self.tcpStreamAlive = false
        case .cancelled:
            self.notifyDelegateOnChange(newStatusFlag: false, connectivityStatus: "cancelled")
            self.tcpStreamAlive = false
            self.setupNWConnection()
            break
        case .preparing:
            self.notifyDelegateOnChange(newStatusFlag: false, connectivityStatus: "preparing")
            self.tcpStreamAlive = true
        @unknown default:
            break
        }
    }
    
    private func setupReceive(on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { (data, contentContext, isComplete, error) in
            // Read data off the stream
            if let data = data, !data.isEmpty {
                let msg = String(data: data, encoding: .ascii)
                if let tempMsg = msg {
                    self.recvMsg = tempMsg
                    self.didRecv = true
                } else {
                    self.recvMsg = "Recv nth"
                    self.didRecv = false
                }
                print("connection did receive \(data.count) bytes, message: \(msg ?? "-")")
            }

            if isComplete || self.didRecv {
//                print("setupReceive: isComplete handle end of stream")
                connection.cancel()
                self.tcpStreamAlive = false
                self.didRecv = false
//                self.setupNWConnection()

            } else if let error = error {
                print("setupReceive: error \(error.localizedDescription)")
                // TODO: Make sure that if the connection needs to be re-established here, it is.
            } else {
                self.setupReceive(on: connection)
            }
        }
    }

    private func sendEndOfStream(connection: NWConnection) {
        connection.send(content: nil, contentContext: .defaultStream, isComplete: true, completion: .contentProcessed({ error in
            print("sendEndOfStream")
            if let error = error {
                //self.connectionDidFail(error: error)
                print("sendEndOfStream: error \(error.localizedDescription)")
            }
        }))
    }

    private func notifyDelegateOnChange(newStatusFlag: Bool, connectivityStatus: String) {
        if newStatusFlag != self.online {
//            print("newStatusFlag: \(newStatusFlag) - connectivityStatus: \(connectivityStatus)")
            self.networkStatusDelegate?.networkStatusChanged(online: newStatusFlag, connectivityStatus: connectivityStatus, msg: self.recvMsg)
            self.online = newStatusFlag
        } else {
//            print("connectivityStatus: \(connectivityStatus)")
        }
    }

}
