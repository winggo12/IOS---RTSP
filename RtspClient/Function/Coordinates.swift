//
//  Coordinates.swift
//  RtspClient
//
//  Created by hkuit155 on 11/3/2021.
//  Copyright © 2021 Andres Rojas. All rights reserved.
//

import Foundation
import UIKit

public struct Coords {
    let camDict: [Int:[Int:Int]] = [1:[1:32, 2:33, 3:34, 4:35, 5:44, 6:45, 7:46, 8:47],
                                    2:[1:28, 2:29, 3:30, 4:31, 5:40, 6:41, 7:42, 8:43],
                                    3:[1:24, 2:25, 3:26, 4:27, 5:36, 6:37, 7:38, 8:39],
                                    4:[1:23, 2:22, 3:21, 4:20, 5:11, 6:10, 7:9, 8:8],
                                    5:[1:19, 2:18, 3:17, 4:16, 5:7, 6:6, 7:5, 8:4],
                                    6:[1:15, 2:14, 3:13, 4:12, 5:3, 6:2, 7:1, 8:0]]
    let customCharSet: CharacterSet = CharacterSet(charactersIn: "}")
    var camLoc: [Int] = []
    var camBbox: [[CGRect]] = [[],[],[],[]]
        
    mutating func extractCoords(msg: String, x: Double, y: Double) {
        
        self.camLoc.removeAll()
        for i in 0...3 {
            self.camBbox[i].removeAll()
        }
        
        // ["#@yyyymmddhhmmss:x,y,bx1,by1,bx2,by2}", "#@yyyymmddhhmmss:x,y,bx1,by1,bx2,by2}"]
        let sigs = msg.components(separatedBy: "{")
        for i in 1..<sigs.count {
            // "#@yyyymmddhhmmss:x,y,bx1,by1,bx2,by2"
            let trimSig = sigs[i].components(separatedBy: "}")
            let camNo = Int(trimSig[0].components(separatedBy: "@")[0]) ?? 0
            let se1 = trimSig[0].components(separatedBy: ":")
            let trimcoords = se1[1].components(separatedBy: ",")
            let rect = CGRect(x: Double(trimcoords[1].trimmingCharacters(in: .whitespaces))!*x, y: Double(trimcoords[2].trimmingCharacters(in: .whitespaces))!*y, width: (Double(trimcoords[3].trimmingCharacters(in: .whitespaces))!-Double(trimcoords[1].trimmingCharacters(in: .whitespaces))!)*x, height: (Double(trimcoords[4].trimmingCharacters(in: .whitespaces))! - Double(trimcoords[2].trimmingCharacters(in: .whitespaces))!)*y)
            
            var loc = Int(trimcoords[0]) ?? 0
            if (loc > 0) {
                self.camLoc.append(self.camDict[camNo]![loc]!)
            }
            self.camBbox[camNo-1].append(rect)
        }
        print(self.camBbox)
    } // extractCoords
}
