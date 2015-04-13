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
        samples.insert(value, atIndex: 0)
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
        var rows = samples.map({self.combineToString($0, with_separator: ",")})
        var row_columns = combineToString(rows, with_separator:"\n")
        let header = "tm,ma,mx,my,mz,ta,aa,ax,ay,az\n"
        return header + row_columns
    }
    
    func combineToString(a: Array<AnyObject>, with_separator s: String) -> String {
//        let sep_length  = count(s)         // for some reason count(s) won't compile
        let sep_length = 1
        var combined = a.reduce("", combine: {"\($0)"+s+"\($1)"})
        let range = combined.startIndex..<advance(combined.startIndex, sep_length)
        combined.removeRange(range)
        return combined
    }
   
    
}
