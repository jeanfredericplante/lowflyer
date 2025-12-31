//
//  SignalProcessingTests.swift
//  LowFlyerTests
//
//  Created by Jules on 10/25/24.
//  Copyright (c) 2024 Jean Frederic Plante. All rights reserved.
//

import UIKit
import XCTest
@testable import LowFlyer

class SignalProcessingTests: XCTestCase {

    func testFFT() {
        let n = 1024
        let sampleRate = 32.0
        let frequency = 4.0 // 4 Hz sine wave
        var data = [Double]()

        for i in 0..<n {
            let t = Double(i) / sampleRate
            let val = sin(2.0 * .pi * frequency * t)
            data.append(val)
        }

        let (frequencies, magnitudes) = SignalProcessing.computeFFT(data: data, sampleRate: sampleRate)

        XCTAssertEqual(frequencies.count, n / 2)
        XCTAssertEqual(magnitudes.count, n / 2)

        // Find peak
        var maxMag = 0.0
        var maxIndex = 0
        for i in 0..<magnitudes.count {
            if magnitudes[i] > maxMag {
                maxMag = magnitudes[i]
                maxIndex = i
            }
        }

        let peakFreq = frequencies[maxIndex]
        print("Peak frequency: \(peakFreq), Magnitude: \(maxMag)")

        // Check if peak is at 4 Hz
        XCTAssertEqual(peakFreq, frequency, accuracy: sampleRate / Double(n))
        // Magnitude should be around 0.5 for sine wave (amplitude 1) split into positive and negative freqs?
        // Accelerate FFT scaling depends on implementation. I used 1/n scaling.
        // For a sine wave A*sin(wt), FFT has two peaks of height A/2.
        // Since we look at single sided spectrum (positive frequencies), but input was real,
        // usually we multiply by 2 for single sided spectrum to get true amplitude.
        // My implementation returned raw magnitude scaled by 1/n.
        // Let's check what we get.
    }
}
