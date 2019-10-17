//: # This Playground Clips audio samples with amplitudes over 0.75.

import Cocoa
import AVFoundation

let src = URL(fileURLWithPath: "/Users/charliecluff/Desktop/SwiftAudioProgramming/SwiftAudioProgramming/10-16-19/HoodRat_HellaGain.wav")

let dst = URL(fileURLWithPath: "/Users/charliecluff/Desktop/SwiftAudioProgramming/SwiftAudioProgramming/10-16-19/HoodRat_Clipped.caf")


let srcFile = try AVAudioFile(forReading: src) // This opens the file for reading

let dstFile = try AVAudioFile(forWriting: dst, settings: srcFile.fileFormat.settings, commonFormat: srcFile.processingFormat.commonFormat, interleaved: srcFile.processingFormat.isInterleaved)

let frameCount = AVAudioFrameCount(srcFile.length) //Copying UFile

guard let buffer = AVAudioPCMBuffer(pcmFormat: srcFile.processingFormat, frameCapacity: frameCount)
    else {
        fatalError("Derp")
}

try srcFile.read(into: buffer, frameCount: frameCount)

for i in stride(from: 0, to: frameCount*2, by: 1) {
    if(buffer.floatChannelData!.pointee[Int(i)] > 0.75) { // Check polarity
        buffer.floatChannelData!.pointee[Int(i)] =
            buffer.floatChannelData!.pointee[Int(i)] * -0.75 // If above 0, multiply by 1
    } else {
        buffer.floatChannelData!.pointee[Int(i)] =
            buffer.floatChannelData!.pointee[Int(i)]
    }
}

try dstFile.write(from:buffer)

