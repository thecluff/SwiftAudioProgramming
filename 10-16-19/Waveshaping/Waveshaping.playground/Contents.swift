//: # This Playground in theory waveshapes audio.

import Cocoa
import AVFoundation

let src = URL(fileURLWithPath: "/Users/charliecluff/Desktop/SwiftAudioProgramming/SwiftAudioProgramming/10-16-19/HoodRat.wav")

let dst = URL(fileURLWithPath: "/Users/charliecluff/Desktop/SwiftAudioProgramming/SwiftAudioProgramming/10-16-19/Waveshaping/HoodRat_Waveshaped.caf")


let srcFile = try AVAudioFile(forReading: src) // This opens the file for reading

let dstFile = try AVAudioFile(forWriting: dst, settings: srcFile.fileFormat.settings, commonFormat: srcFile.processingFormat.commonFormat, interleaved: srcFile.processingFormat.isInterleaved)

let frameCount = AVAudioFrameCount(srcFile.length) //Copying UFile

guard let buffer = AVAudioPCMBuffer(pcmFormat: srcFile.processingFormat, frameCapacity: frameCount)
    else {
        fatalError("Derp")
}

try srcFile.read(into: buffer, frameCount: frameCount)


for i in stride(from: 0, to: frameCount*2, by: 1){
        buffer.floatChannelData!.pointee[Int(i)] =
            tanh( 3 * buffer.floatChannelData!.pointee[Int(i)]) / tanh(3)
}

try dstFile.write(from:buffer)

