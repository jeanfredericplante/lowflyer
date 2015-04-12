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

protocol ZipperUpdateDelegate {
    func didUpdateMagneticField()
    func didUpdateAccelerationField()
}

class ZipperMeter : NSObject {
    
    struct Params {
        static let samplingTime: NSTimeInterval = 0.03
    }
    
    var delegate: ZipperUpdateDelegate?
    var magneticAmplitude: Double {
        get {
            return vectorAmplitude(magneticField)
        }
    }
    var accelerationAmplitude: Double {
        get {
            return vectorAmplitude(accelerationField)
        }
    }
    var magneticField: [Double] = Array(count: 3, repeatedValue: 0)
    var magneticSampleTime: NSTimeInterval = 0
    var accelerationSampleTime: NSTimeInterval = 0
    var accelerationField: [Double] = Array(count: 3, repeatedValue: 0)
    var magnitudeHistory = [NSManagedObject]()
    let motionManager = AppDelegate.Motion.Manager
    let motionQueue = NSOperationQueue()
    

    
    func isAvailable() -> Bool {
        return motionManager.magnetometerAvailable && motionManager.accelerometerAvailable
    }
    
    func startMonitoring() -> Void {
        if motionManager.magnetometerAvailable {
            motionManager.magnetometerUpdateInterval = Params.samplingTime
            motionManager.startMagnetometerUpdatesToQueue(motionQueue, withHandler:
                {(data: CMMagnetometerData!, error: NSError!) in
                    // TODO: handle error case
                    self.magneticField[0] = data.magneticField.x
                    self.magneticField[1] = data.magneticField.y
                    self.magneticField[2] = data.magneticField.z
                    self.magneticSampleTime = data.timestamp
                    dispatch_async(dispatch_get_main_queue()) {
                        if let d = self.delegate {
                            d.didUpdateMagneticField()
                        }
                    }
            })
        }
        if motionManager.accelerometerAvailable {
            motionManager.accelerometerUpdateInterval = Params.samplingTime
            motionManager.startAccelerometerUpdatesToQueue(motionQueue) { (data, error) -> Void in
                self.accelerationField[0] = data.acceleration.x
                self.accelerationField[1] = data.acceleration.y
                self.accelerationField[2] = data.acceleration.z
                self.accelerationSampleTime = data.timestamp

                dispatch_async(dispatch_get_main_queue()) {
                    if let d = self.delegate {
                        d.didUpdateAccelerationField()
                    }
                }
            }
        }
    }
    
    func stopMonitoring() -> Void {
        motionManager.stopMagnetometerUpdates()
    }
    
    var measurementRow: [Double] {
        // mag amplitude, mag x, mag y, mag z
        get {
            var row1 = self.magneticField
            row1.insert(self.magneticAmplitude, atIndex: 0)
            row1.insert(magneticSampleTime, atIndex: 0)
            var row2 = self.accelerationField
            row2.insert(self.accelerationAmplitude, atIndex: 0)
            row2.insert(accelerationSampleTime, atIndex: 0)
            row1 += row2
            return row1
        }
    }
    
    private func vectorAmplitude(vec: [Double]) -> Double {
        return sqrt(vec.reduce(0, combine: {$0 + $1*$1}))
    }
    
     
    

}
