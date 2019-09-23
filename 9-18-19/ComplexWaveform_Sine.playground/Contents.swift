//: # Complex waveform
//: Use sinewaves to synthesize (or compose) a complex waveform.
//: This makes use of the __Fourier theorem__, i.e., *Any complex*
//: *periodic waveform can be decomposed into the __sum__ of an*
//: *arbitrary numbere of sinewaves.*

import Cocoa

func sinewave(sampleRate: Double, frequency: Double, amplitude: Double, nSamples: Int) -> [Double] {
    var wave = [Double]()
    
    for ndx in 0...nSamples {
        wave.append(amplitude * sin(2 * Double.pi * Double(ndx) * frequency / sampleRate))
    }
    return wave
}

// let newSine = sinewave(sampleRate: 44100, frequency: 441.0, amplitude: 1.0, nSamples: 2000)
// newSine.map() {$0}

//: The objective is add sinewaves together to make a complex waveform. We will use the sinewave function to generate each harmonic.

func cmplxWave(sampleRate: Double, frequency: Double, amplitude: Double, nSamples: Int, numHarmonics: Int) -> [Double] {
    var sine = [Double]()
    var cmplx = [Double](repeating: 0.0, count: nSamples)
    
    //: Looping the number of harmonics
    for k in 1...numHarmonics {
        sine = sinewave(sampleRate: sampleRate, frequency: Double(k) * frequency, amplitude: Double(1)/Double(k), nSamples: nSamples)
        
        cmplx = zip(cmplx, sine).map {
            ($0.0 + $0.1)
        }
    }
    return cmplx
}

let sawWave = cmplxWave(sampleRate: 44100, frequency: 200, amplitude: 1.0, nSamples: 1000, numHarmonics: 17)
sawWave.map() {$0}

//: The above (line 28) assumes that every harmonic will be calculated. In many cases we do not calculate every harmonic.
//: Two examples are square waves, and triangle waves.
//: In a square wave, we only calculate the odd numbered harmonic, in other words 1, 3, 5, 7, ...
//: But, the harmonic amplitudes are the same as for sawtooth. i.e., 1/k
//: To make the loop in line 28 increment by two, rather than by one, we need a slightly different syntax.
//: For k in stride(from: 1, to: numHarmonics, by 2)
//: ### Coding assigment for next class period
//: Code a square wave, based on the example above. How many harmonics does it take to make the square wave *square*?
//: Answer: 9
