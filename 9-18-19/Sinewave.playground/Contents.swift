//: ## Sinewave generation step 1

import Cocoa

//: The number of points calculated
let nPts = 256

//: This is the waveform buffer
var sinewave = [Double]()

//: A loop to calculate the waveform points
var amp = 0.5
var freq = 2.0
var phase = Double.pi / 2

for ndx in 1...nPts {
    sinewave.append(amp * sin(2 * Double.pi * freq * Double(ndx) / Double(nPts) + phase))
}

sinewave.map() {$0}
