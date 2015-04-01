//
//  MagnetoMeter.swift
//  LowFlyer
//
//  Created by Jean Frederic Plante on 3/29/15.
//  Copyright (c) 2015 Jean Frederic Plante. All rights reserved.
//

import Foundation
import CoreMotion
import CoreData

protocol MagnetoUpdateDelegate {
    func didUpdateMagneticField()
}

class MagnetoMeter : NSObject {
    
    struct Params {
        static let samplingTime = 0.03
    }
    
    var delegate: MagnetoUpdateDelegate?
    var magnitude: Double {
        get {
            return sqrt(magneticField.reduce(0, combine: {$0 + $1*$1}))
        }
    }
    var magneticField: [Double] = Array(count: 3, repeatedValue: 0)
    var magnitudeHistory = [NSManagedObject]()
    let motionManager = CMMotionManager()
    let motionQueue = NSOperationQueue()
    
    func isAvailable() -> Bool {
        return motionManager.magnetometerAvailable
    }
    
    func startMonitoring() -> Void {
        motionManager.startMagnetometerUpdatesToQueue(motionQueue, withHandler:
            {(data: CMMagnetometerData!, error: NSError!) in
                // TODO: handle error case
                self.magneticField[0] = data.magneticField.x
                self.magneticField[1] = data.magneticField.y
                self.magneticField[2] = data.magneticField.z
                self.saveMagnitude(self.magnitude)
                dispatch_async(dispatch_get_main_queue()) {
                    if let d = self.delegate {
                        d.didUpdateMagneticField()
                    }
                }
        })
    }
    
    func stopMonitoring() -> Void {
        motionManager.stopMagnetometerUpdates()
    }
    
     
    

}
