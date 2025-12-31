//
//  ZipperDetector.swift
//  LowFlyer
//
//  Created by Jules on 10/25/24.
//  Copyright (c) 2024 Jean Frederic Plante. All rights reserved.
//

import Foundation

class ZipperDetector {

    // Configurable parameters
    var sampleRate: Double = 1.0 / ZipperMeter.Params.samplingTime // Use dynamic rate if possible or default to ZipperMeter param
    let windowSize: Int = 1024 // Power of 2
    let minWalkFreq: Double = 0.5
    let maxWalkFreq: Double = 5.0

    // Threshold for detection.
    // If (Amplitude at 2nd Harmonic) / (Amplitude at Fundamental) > threshold, then OPEN.
    // This is a heuristic.
    var harmonicRatioThreshold: Double = 0.4

    init() {
        // Initialize with default
        if ZipperMeter.Params.samplingTime > 0 {
            sampleRate = 1.0 / ZipperMeter.Params.samplingTime
        } else {
            sampleRate = 33.0
        }
    }

    func detect(samples: [Double]) -> (isOpen: Bool, ratio: Double, fundamentalFreq: Double) {
        guard samples.count >= windowSize else {
            return (false, 0.0, 0.0)
        }

        // Take the latest windowSize samples
        let recentSamples = Array(samples.suffix(windowSize))

        let (frequencies, magnitudes) = SignalProcessing.computeFFT(data: recentSamples, sampleRate: sampleRate)

        guard !frequencies.isEmpty else {
            return (false, 0.0, 0.0)
        }

        // Find peak in walking frequency range
        var maxVal = 0.0
        var maxIndex = 0

        for (i, freq) in frequencies.enumerated() {
            if freq >= minWalkFreq && freq <= maxWalkFreq {
                if magnitudes[i] > maxVal {
                    maxVal = magnitudes[i]
                    maxIndex = i
                }
            }
        }

        let fundamentalFreq = frequencies[maxIndex]
        let fundamentalMag = maxVal

        if fundamentalMag == 0 {
             return (false, 0.0, 0.0)
        }

        // Find magnitude at 2nd harmonic (2 * fundamentalFreq)
        let harmonicFreq = 2.0 * fundamentalFreq

        // Find index closest to harmonicFreq
        let df = frequencies[1] - frequencies[0] // frequency resolution
        let harmonicIndex = Int(round(harmonicFreq / df))

        var harmonicMag = 0.0
        if harmonicIndex < magnitudes.count {
            harmonicMag = magnitudes[harmonicIndex]
        }

        let ratio = harmonicMag / fundamentalMag
        let isOpen = ratio > harmonicRatioThreshold

        print("Zipper Analysis: F_walk=\(fundamentalFreq)Hz (Amp=\(fundamentalMag)), F_2nd=\(harmonicFreq)Hz (Amp=\(harmonicMag)), Ratio=\(ratio), Open=\(isOpen)")

        return (isOpen, ratio, fundamentalFreq)
    }
}
