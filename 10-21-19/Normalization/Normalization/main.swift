//: # Read -> Write Audio + Gain
//: Transfer audio content from one file to another, in order to learn mechanics of audio file I/O.

import Cocoa
import AVFoundation

let src = URL(fileURLWithPath: "/Users/charliecluff/Desktop/SwiftAudioProgramming/SwiftAudioProgramming/10-21-19/mixAudioA.wav")
let dst = URL(fileURLWithPath: "/Users/charliecluff/Desktop/SwiftAudioProgramming/SwiftAudioProgramming/10-21-19/mixAudioA_Normalized.caf")

let SAMPLE_RATE = 44100.0

var normFactor: Float = 0.0

let srcFile = try AVAudioFile(forReading: src)
let dstFile = try AVAudioFile(forWriting: dst, settings: srcFile.fileFormat.settings, commonFormat: srcFile.processingFormat.commonFormat, interleaved: srcFile.processingFormat.isInterleaved)

let outputFormatSettings = [
    AVFormatIDKey: kAudioFormatLinearPCM,
    AVLinearPCMBitDepthKey: 32,
    AVLinearPCMIsFloatKey: true,
    AVSampleRateKey: SAMPLE_RATE,
    AVNumberOfChannelsKey: 2
    ] as [String: Any]

//: Declare the frame count
let frameCount = AVAudioFrameCount(srcFile.length)
guard let buffer = AVAudioPCMBuffer(pcmFormat: srcFile.processingFormat, frameCapacity: frameCount)
    else {
        fatalError("Derp")
}

//: Read, then write the audio samples from one file to another
try srcFile.read(into: buffer, frameCount: frameCount)

// Determine normalization factor
for i in 0...frameCount*2{
    if(abs(buffer.floatChannelData!.pointee[Int(i)]) > normFactor){
        normFactor = abs(buffer.floatChannelData!.pointee[Int(i)])
    }
}

// Apply the normalization factor
for i in 0...frameCount*2 {
    buffer.floatChannelData!.pointee[Int(i)] =  buffer.floatChannelData!.pointee[Int(i)] * normFactor
}

try dstFile.write(from: buffer)
