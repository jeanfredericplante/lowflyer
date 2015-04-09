//
//  MeasurementSamples.swift
//  LowFlyer
//
//  Created by Jean Frederic Plante on 4/8/15.
//  Copyright (c) 2015 Jean Frederic Plante. All rights reserved.
//

import Foundation

class MeasurementSamples {
    
    var maxSamples = 1000
    var samples = [Double]()
    var count: Int {
        get {
            return samples.count    
        }
    }
    
    init(maxSamples: Int) {
        self.maxSamples = maxSamples
    }
    
    func add(value: Double) {
        samples.insert(value, atIndex: 0)
        if samples.count > maxSamples {
            samples.removeLast()
        }
    }
    
    func getLast() -> Double? {
        if samples.count > 0 {
            return samples[0]
        } else {
            return nil
        }
    }
    
    func samplesAsCSVString() -> String {
        return samples.reduce("start", combine: {"\($0),\($1)"})
    }
     
   
    
}
