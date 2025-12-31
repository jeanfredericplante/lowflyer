//
//  SignalProcessing.swift
//  LowFlyer
//
//  Created by Jules on 10/25/24.
//  Copyright (c) 2024 Jean Frederic Plante. All rights reserved.
//

import Foundation
import Accelerate

class SignalProcessing {

    static func computeFFT(data: [Double], sampleRate: Double) -> (frequencies: [Double], magnitudes: [Double]) {
        let n = data.count
        let log2n = vDSP_Length(log2(Double(n)))

        // n must be a power of 2
        guard Int(pow(2.0, Double(log2n))) == n else {
            print("Input data length must be a power of 2 for FFT")
            return ([], [])
        }

        let halfN = n / 2

        // Create the FFT setup
        guard let fftSetup = vDSP_create_fftsetupD(log2n, FFTRadix(kFFTRadix2)) else {
            print("Failed to create FFT setup")
            return ([], [])
        }

        // Prepare inputs
        var real = data
        var imag = [Double](repeating: 0.0, count: n)
        var realOut = [Double](repeating: 0.0, count: halfN)
        var imagOut = [Double](repeating: 0.0, count: halfN)


        // Perform FFT
        // We use vDSP_fft_zipD for complex FFT.
        // We need to split the complex buffer.

        var complexBuffer = DSPDoubleSplitComplex(realp: &real, imagp: &imag)

        // Execute FFT
        vDSP_fft_zipD(fftSetup, &complexBuffer, 1, log2n, FFTDirection(FFT_FORWARD))

        // Calculate magnitudes
        // The result is in complexBuffer.
        // We are interested in the first halfN elements (0 to Nyquist frequency)
        // vDSP_zvabsD computes magnitude squared or absolute value? zvmagsD is squared magnitude, zvabsD is absolute.
        // Matlab code uses abs(Y).

        var magnitudes = [Double](repeating: 0.0, count: halfN)

        // We need to be careful with the layout. vDSP_fft_zipD output is packed.
        // However, since we passed separate arrays, real and imag contain the results.
        // But for real input, the output has symmetry.
        // Let's use vDSP_zvmagsD to get squared magnitudes and then sqrt, or vDSP_zvabsD directly if available.
        // vDSP_zvabsD is available.

        // We need to construct a split complex for the first half.
        // Note: The DC component is at real[0], and Nyquist is at imag[0] in the packed format usually,
        // but vDSP_fft_zipD assumes complex input.

        // Wait, if input is real, we should put it in the real part and 0 in imag part.
        // Then the output will be symmetric. We only need the first n/2.

        // Actually, if we use vDSP_fft_zipD, it does a complex FFT.
        // Since our input is real, we put data in realp and 0 in imagp.

        var splitComplex = DSPDoubleSplitComplex(realp: &real, imagp: &imag)

        vDSP_zvabsD(&splitComplex, 1, &magnitudes, 1, vDSP_Length(halfN))

        // Normalize
        var scale = 1.0 / Double(n)
        vDSP_vsmulD(magnitudes, 1, &scale, &magnitudes, 1, vDSP_Length(halfN))

        // Calculate frequencies
        var frequencies = [Double](repeating: 0.0, count: halfN)
        let frequencyStep = sampleRate / Double(n)
        for i in 0..<halfN {
            frequencies[i] = Double(i) * frequencyStep
        }

        // Clean up
        vDSP_destroy_fftsetupD(fftSetup)

        return (frequencies, magnitudes)
    }
}
