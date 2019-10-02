//: # Read -> Write Audio + Gain
//: Transfer audio content from one file to another, in order to learn mechanics of audio file I/O.

import Cocoa
import AVFoundation

let src = URL(fileURLWithPath: "/Users/charliecluff/Desktop/SwiftAudioProgramming/SwiftAudioProgramming/exampleAudio/Fahrenheit451.wav")
let dst = URL(fileURLWithPath: "/Users/charliecluff/Desktop/SwiftAudioProgramming/SwiftAudioProgramming/exampleAudio/Fahrenheit451_Gain.caf")

let SAMPLE_RATE = 44100.0

let srcFile = try AVAudioFile(forReading: src)
let dstFile = try AVAudioFile(forWriting: dst, settings: srcFile.fileFormat.settings, commonFormat: srcFile.processingFormat.commonFormat, interleaved: srcFile.processingFormat.isInterleaved)

//: Declare the frame count
let frameCount = AVAudioFrameCount(srcFile.length)
guard let buffer = AVAudioPCMBuffer(pcmFormat: srcFile.processingFormat, frameCapacity: frameCount)
    else {
        fatalError("Derp")
}

//: Read, then write the audio samples from one file to another
try srcFile.read(into: buffer, frameCount: frameCount)

//: Loop through the buffer and change the amplitudes of the samples by a constant factor. (i.e., gain)
//: When the samples are in the audio files, they are interleaved. They are read into the buffer de-interleaved.
//: In other words, all the samples in one channel are contiguous, followed by all of the samples from the other channel.

for i in stride(from: 0, to: frameCount, by: 2){
    buffer.floatChannelData!.pointee[Int(i)] =  buffer.floatChannelData!.pointee[Int(i)] * 1.5
}

try dstFile.write(from: buffer)

//let newFile = try AVAudioFile(forReading: src)
//
//let outputFormatSettings = [
//    AVFormatIDKey: kAudioFormatLinearPCM,
//    AVLinearPCMBitDepthKey: 32,
//    AVLinearPCMIsFloatKey: true,
//    AVSampleRateKey: SAMPLE_RATE,
//    AVNumberOfChannelsKey: 2
//    ] as [String: Any]
//
//let audioFile = dstFile
//
//let bufferFormat = AVAudioFormat(settings:outputFormatSettings)
//let outputBuffer = AVAudioPCMBuffer(pcmFormat: bufferFormat!, frameCapacity: AVAudioFrameCount(frameCount))
//
//for i in 0...frameCount {
//    outputBuffer?.floatChannelData!.pointee[Int(i*2)] = Float(newFile[i])
//    outputBuffer?.floatChannelData!.pointee[Int(i*2-1)] = Float(newFile[i]) * 1.5
//}
//outputBuffer!.frameLength = AVAudioFrameCount(frameCount)
//
//do {
//    try dstFile.write(from: outputBuffer!)
//} catch let error as NSError{
//    print("error:", error.localizedDescription)
//}
