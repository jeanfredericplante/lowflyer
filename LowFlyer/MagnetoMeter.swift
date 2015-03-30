//
//  MagnetoMeter.swift
//  LowFlyer
//
//  Created by Jean Frederic Plante on 3/29/15.
//  Copyright (c) 2015 Jean Frederic Plante. All rights reserved.
//

import Foundation
import CoreMotion

class MagnetoMeter {
    
    struct Params {
        static let samplingTime = 1/30
    }
    
    var magnitude: Double?
    let motionManager = CMMotionManager()
    let motionQueue = NSOperationQueue()
    
    func isAvailable() -> Bool {
        return motionManager.magnetometerAvailable
    }
    
    func startMonitoring() -> Void {
        
    }
    

}
