//
//  Json.swift
//  RtspClient
//
//  Created by hkuit155 on 19/2/2021.
//  Copyright © 2021 Andres Rojas. All rights reserved.
//

import Foundation

public struct Json {
    static var addressData = address(server_ip: "", server_port: 0, cam_urls: ["rtsp://192.168.50.3:554/user=admin&password=Hkumb155&channel=1&stream=0.rsp", "rtsp://192.168.50.4:554/user=admin&password=Hkumb155&channel=1&stream=0.rsp", "", ""])
    
    static let docPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    static func writeJson() {
        let outputJson = addressData
        let encoder = JSONEncoder()
        let data: Data
        data = try! encoder.encode(outputJson)
        print(data)
        let filePath = docPath[0].appendingPathComponent("config.json")
        do {
            try data.write(to: filePath)
            print(filePath)
            return
        } catch {
            print("write json error!")
            return
        }
    }
    
    static func readJson() {
        var readFile: FileHandle? = nil
        do {
            readFile = try FileHandle(forReadingFrom: Json.docPath[0].appendingPathComponent("config.json"))
        } catch {
            print("config.json not found, creating default files...")
            return
        }
        if readFile != nil {
            let decoder = JSONDecoder()
            let buffer = readFile!.readDataToEndOfFile();
            let addresses = try! decoder.decode(address.self, from: buffer)
            print(addresses)
            addressData = addresses
            return
        } else {
            Json.writeJson()
            return
        }
    } // readJson
}
