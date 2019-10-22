import Cocoa
import AVFoundation

let srcA = URL(fileURLWithPath: "/Users/charliecluff/Desktop/SwiftAudioProgramming/SwiftAudioProgramming/10-21-19/mixAudioA.wav")
let srcB = URL(fileURLWithPath: "/Users/charliecluff/Desktop/SwiftAudioProgramming/SwiftAudioProgramming/10-21-19/mixAudioB.wav")

let dst = URL(fileURLWithPath: "/Users/charliecluff/Desktop/SwiftAudioProgramming/SwiftAudioProgramming/10-21-19/mixAudioSummed.caf")

let SAMPLE_RATE = 44100.0

let srcFileA = try AVAudioFile(forReading: srcA)
let srcFileB = try AVAudioFile(forReading: srcB)

let dstFile = try AVAudioFile(forWriting: dst, settings: srcFileA.fileFormat.settings, commonFormat: srcFileA.processingFormat.commonFormat, interleaved: srcFileA.processingFormat.isInterleaved)

let frameCountA = AVAudioFrameCount(srcFileA.length)

guard let bufferA = AVAudioPCMBuffer(pcmFormat: srcFileA.processingFormat, frameCapacity: frameCountA)
    else {
        fatalError("Derp")
}

let frameCountB = AVAudioFrameCount(srcFileB.length)

guard let bufferB = AVAudioPCMBuffer(pcmFormat: srcFileB.processingFormat, frameCapacity: frameCountB)
    else {
        fatalError("Derp")
}

guard let outBuf = AVAudioPCMBuffer(pcmFormat: srcFileA.processingFormat, frameCapacity: frameCountA)
    else {
        fatalError("Derp")
}

try srcFileA.read(into: bufferA, frameCount: frameCountA)

try srcFileB.read(into: bufferB, frameCount: frameCountB)

for i in 0...frameCountA*2{
    outBuf.floatChannelData!.pointee[Int(i)] = bufferA.floatChannelData!.pointee[Int(i)] + bufferB.floatChannelData!.pointee[Int(i)]

}

outBuf.frameLength = AVAudioFrameCount(frameCountA)

do {
    try dstFile.write(from: outBuf)
} catch let error as NSError{
    print("error:", error.localizedDescription)
}
