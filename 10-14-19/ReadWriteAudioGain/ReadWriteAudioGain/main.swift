import Cocoa
import AVFoundation

let src = URL(fileURLWithPath: "/Users/charliecluff/Desktop/SwiftAudioProgramming/SwiftAudioProgramming/10-14-19/DillaOrgan.wav")
let dst = URL(fileURLWithPath: "/Users/charliecluff/Desktop/SwiftAudioProgramming/SwiftAudioProgramming/10-14-19/DillaOrgan_GainMono.caf")

let SAMPLE_RATE = 44100.0

let srcFile = try AVAudioFile(forReading: src)

let fileFormat = srcFile.fileFormat

let outputFormatSettings = [
    AVFormatIDKey: kAudioFormatLinearPCM,
    AVLinearPCMBitDepthKey: 32,
    AVLinearPCMIsFloatKey: true,
    AVSampleRateKey: srcFile.fileFormat.sampleRate,
    AVNumberOfChannelsKey: 1
    ] as [String: Any]

let dstFile = try AVAudioFile(forWriting: dst, settings: outputFormatSettings, commonFormat: srcFile.processingFormat.commonFormat, interleaved: srcFile.processingFormat.isInterleaved)

//: Declare the frame count
let frameCount = AVAudioFrameCount(srcFile.length)
let channelCount = srcFile.fileFormat.channelCount
guard let buffer = AVAudioPCMBuffer(pcmFormat: srcFile.processingFormat, frameCapacity: frameCount)
    else {
        fatalError("Derp")
}

guard let tempBuffer = AVAudioPCMBuffer(pcmFormat: dstFile.processingFormat, frameCapacity: frameCount)
    else {
        fatalError("Derp")
}

//: Read, then write the audio samples from one file to another
try srcFile.read(into: buffer, frameCount: frameCount)

//: Loop through the buffer and change the amplitudes of the samples by a constant factor. (i.e., gain)
//: When the samples are in the audio files, they are interleaved. They are read into the buffer de-interleaved.
//: In other words, all the samples in one channel are contiguous, followed by all of the samples from the other channel.

for i in 0..<frameCount {
    tempBuffer.floatChannelData!.pointee[Int(i)] =  buffer.floatChannelData!.pointee[Int(i)] + buffer.floatChannelData!.pointee[Int(i) + Int(frameCount)] * 0.5
}

print(tempBuffer.frameCapacity)

try dstFile.write(from: tempBuffer)
