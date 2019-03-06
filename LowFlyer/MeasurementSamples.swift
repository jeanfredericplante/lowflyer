//
//  MeasurementSamples.swift
//  LowFlyer
//
//  Created by Jean Frederic Plante on 4/8/15.
//  Copyright (c) 2015 Jean Frederic Plante. All rights reserved.
//

import Foundation

class MeasurementSamples {
    
    var maxSamples = 1024
    var samples = [[Double]]()
    var count: Int {
        get {
            return samples.count    
        }
    }
    
    init(maxSamples: Int) {
        self.maxSamples = maxSamples
    }
    
    func add(value: [Double]) {
        samples.insert(value, at: 0)
        if samples.count > maxSamples {
            samples.removeLast()
        }
    }
    
    func getLast() -> [Double]? {
        if samples.count > 0 {
            return samples[0]
        } else {
            return nil
        }
    }
    
    func clear() {
        samples = [[Double]]()
    }
    
    func samplesAsCSVString() -> String {
        let rows = samples.map({self.combineToString(a: $0, with_separator: ",")})
        let row_columns = rows.joined(separator: "\n")
        let header = "tm,ma,mx,my,mz,ta,aa,ax,ay,az\n"
        return header + row_columns
    }
    
    func combineToString(a: Array<Double>, with_separator s: String) -> String {
        let csv_row = a.map({"\($0)"}).joined(separator: s)
        return csv_row
    }
   
    
}
