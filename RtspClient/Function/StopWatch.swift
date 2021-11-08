//
//  Timer.swift
//  RtspClient
//
//  Created by Jai Wing on 11/10/2021.
//  Copyright © 2021 Andres Rojas. All rights reserved.
//

import Foundation

public class StopWatch {
    
    var start = DispatchTime.now()
    var end = DispatchTime.now()
    var currentTime = DispatchTime.now()
    
    func startCount(){
        start = DispatchTime.now()
    }
    
    func endCount(){
        end = DispatchTime.now()
    }
    
    //Check the time between the start and current time
    func intermediateResult()->Double{
        currentTime = DispatchTime.now()
        let nanoTime = currentTime.uptimeNanoseconds - start.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1_000_000_000

        return timeInterval
    }
    
    func result() -> Double{
        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1_000_000_000
        
        return timeInterval
    }
    
}
