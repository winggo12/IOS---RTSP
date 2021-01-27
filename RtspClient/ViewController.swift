//
//  ViewController.swift
//  RtspClient
//
//  Created by Teocci on 18/05/16.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    @IBOutlet weak var ipInput: UITextField!
    @IBOutlet weak var portInput: UITextField!
    @IBOutlet weak var msgOutput: UILabel!
    @IBOutlet weak var greenLed: UIImageView!
    @IBOutlet weak var yellowLed: UIImageView!
    @IBOutlet weak var redLed: UIImageView!
    
    var video1: RTSPPlayer!
    var video2: RTSPPlayer!
    var videoSetupOnce = false
    
    var client = NetworkConnectivity(host: "", port: 0)
    
    var bboxRect: [Double] = [0, 0, 0, 0]
    
    @IBAction func connectBtn(_ sender: UIButton) {
        if !videoSetupOnce {
            videoSetup()
            videoSetupOnce = true
        }
        initClient(host: self.ipInput.text ?? "localhost", port: Int((self.portInput.text! as NSString).intValue))
    }
    @IBAction func disconnectBtn(_ sender: UIButton) {
        stopClient()
    }
    
    func initClient(host: String, port: Int) {
        self.client.updateAddress(host: host, port: port)
        self.client.setup()
    }
    
    func stopClient() {
        self.client.stop()
    }
    
    func videoSetup()
    {
        /// Lab: 44
        /// Pool: 40,41,42,50
        video1 = RTSPPlayer(video: "rtsp://192.168.50.44:554/user=admin&password=Hkumb155&channel=1&stream=0.rsp", usesTcp: true)
        
        if video1 != nil {
            video1.outputWidth = Int32(imageView1.bounds.width)
            video1.outputHeight = Int32(imageView1.bounds.height)
            video1.seekTime(0.0)
            
            let timer1 = Timer.scheduledTimer(timeInterval: 1.0/30, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
              timer1.fire()
        }

//        video2 = RTSPPlayer(video: "rtsp://192.168.50.44:554/user=admin&password=Hkumb155&channel=1&stream=0.rsp", usesTcp: true)
//
//        if video2 != nil {
//            video2.outputWidth = Int32(imageView2.bounds.width)
//            video2.outputHeight = Int32(imageView2.bounds.height)
//            video2.seekTime(0.0)
//
//            let timer2 = Timer.scheduledTimer(timeInterval: 1.0/50, target: self, selector: #selector(ViewController.update2), userInfo: nil, repeats: true)
//              timer2.fire()
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.client.networkStatusDelegate = self
    }
    
    @objc func update(timer: Timer) {
        if(!video1.stepFrame()){
            timer.invalidate()
            video1.closeAudio()
        }
//        imageView1.image = video1.currentImage
        imageView1.image = drawBbox(img: video1.currentImage)
    }
    
    @objc func update2(timer2: Timer) {

        if(!video2.stepFrame()){
            timer2.invalidate()
            video2.closeAudio()
        }
        imageView2.image = video2.currentImage
    }
    
    func drawBbox(img: UIImage) -> UIImage
    {
        let imgSize = img.size
        
        UIGraphicsBeginImageContextWithOptions(imgSize, false, 1.0)
        let context = UIGraphicsGetCurrentContext()
        img.draw(at: CGPoint.zero)
        let rectangle = CGRect(x: bboxRect[0] * Double(imgSize.width), y: bboxRect[1] * Double(imgSize.height), width: bboxRect[2] * Double(imgSize.width), height: bboxRect[3] * Double(imgSize.height))
        context?.setLineWidth(5.0)
        UIColor.red.set()
        context?.addRect(rectangle)
        context?.strokePath()
        let newImg = UIGraphicsGetImageFromCurrentImageContext() ?? img
        UIGraphicsEndImageContext()
        return newImg
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: NetworkConnectivityDelegate {
    func networkStatusChanged(online: Bool, connectivityStatus: String, msg: String) {
        DispatchQueue.main.async {
            self.msgOutput.text = msg
            if msg != "" {
                let firstChar = msg[msg.index(msg.startIndex, offsetBy: 0)]
                switch firstChar {
                case "0":
                    self.imageView1.layer.borderColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1).cgColor
                    self.imageView1.layer.borderWidth = 5
                    self.greenLed.image = UIImage(named: "greenon.png")
                    self.redLed.image = UIImage(named: "redoff")
                    self.yellowLed.image = UIImage(named: "yellowoff")
                    self.bboxRect = [0, 0, 0, 0]
                case "1":
                    self.imageView1.layer.borderColor = UIColor(red: 1, green: 1, blue: 0, alpha: 1).cgColor
                    self.imageView1.layer.borderWidth = 5
                    self.greenLed.image = UIImage(named: "greenoff")
                    self.redLed.image = UIImage(named: "redoff")
                    self.yellowLed.image = UIImage(named: "yellowon")
                    self.bboxRect = [0, 0, 0, 0]
                case "2":
                    self.imageView1.layer.borderColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1).cgColor
                    self.imageView1.layer.borderWidth = 5
                    self.greenLed.image = UIImage(named: "greenoff")
                    self.redLed.image = UIImage(named: "redon")
                    self.yellowLed.image = UIImage(named: "yellowoff")
                    let bbox = msg.components(separatedBy: ", ")
                    self.bboxRect = [Double(bbox[1])!, Double(bbox[2])!, (Double(bbox[3])! - Double(bbox[1])!), (Double(bbox[4])! - Double(bbox[2])!)]
                default:
                    break
                }
            }
        }
    }
}
