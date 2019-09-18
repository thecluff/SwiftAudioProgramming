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
