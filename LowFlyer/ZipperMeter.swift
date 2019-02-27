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
        static let samplingTime: TimeInterval = 0.03
    }
    
    var delegate: ZipperUpdateDelegate?
    var magneticAmplitude: Double {
        get {
            return vectorAmplitude(vec: magneticField)
        }
    }
    var accelerationAmplitude: Double {
        get {
            return vectorAmplitude(vec: accelerationField)
        }
    }
    var magneticField: [Double] = Array(repeating: 0, count: 3)
    var magneticSampleTime: TimeInterval = 0
    var accelerationSampleTime: TimeInterval = 0
    var accelerationField: [Double] = Array(repeating: 0, count: 3)
    var magnitudeHistory = [NSManagedObject]()
    let motionManager = AppDelegate.Motion.Manager
    let motionQueue = OperationQueue()
    

    
    func isAvailable() -> Bool {
        return motionManager.isMagnetometerAvailable && motionManager.isAccelerometerAvailable
    }
    
    func startMonitoring() -> Void {
        if motionManager.isMagnetometerAvailable {
            motionManager.magnetometerUpdateInterval = Params.samplingTime
            motionManager.startMagnetometerUpdates(to: motionQueue, withHandler:
                {(data: CMMagnetometerData!, error: NSError!) in
                    // TODO: handle error case
                    self.magneticField[0] = data.magneticField.x
                    self.magneticField[1] = data.magneticField.y
                    self.magneticField[2] = data.magneticField.z
                    self.magneticSampleTime = data.timestamp
                    DispatchQueue.main.async {
                        if let d = self.delegate {
                            d.didUpdateMagneticField()
                        }
                    }
                    } as! CMMagnetometerHandler)
        }
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = Params.samplingTime
            motionManager.startAccelerometerUpdates(to: motionQueue) { (data, error) -> Void in
                self.accelerationField[0] = data?.acceleration.x ?? 0
                self.accelerationField[1] = data?.acceleration.y ?? 0
                self.accelerationField[2] = data?.acceleration.z ?? 0
                self.accelerationSampleTime = data?.timestamp ?? 0

                DispatchQueue.main.async {
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
            row1.insert(self.magneticAmplitude, at: 0)
            row1.insert(magneticSampleTime, at: 0)
            var row2 = self.accelerationField
            row2.insert(self.accelerationAmplitude, at: 0)
            row2.insert(accelerationSampleTime, at: 0)
            row1 += row2
            return row1
        }
    }
    
    private func vectorAmplitude(vec: [Double]) -> Double {
        return sqrt(vec.reduce(0, combine: {$0 + $1*$1}))
    }
    
     
    

}
