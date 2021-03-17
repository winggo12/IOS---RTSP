//
//  Address.swift
//  RtspClient
//
//  Created by hkuit155 on 19/2/2021.
//  Copyright © 2021 Andres Rojas. All rights reserved.
//

import Foundation

struct address: Codable {
    var server_ip: String
    var server_port: Int
    var cam_urls: [String]
}
