import Cocoa
import AVFoundation

var normFac: Float = 0.0

let srcPath = "/Users/charliecluff/Desktop/SwiftAudioProgramming/SwiftAudioProgramming/10-23-19/DillaLow.wav"

let dstPath = "/Users/charliecluff/Desktop/SwiftAudioProgramming/SwiftAudioProgramming/10-23-19/DillaNorm.caf"

let src = URL(fileURLWithPath: srcPath)
let dst = URL(fileURLWithPath: dstPath)

let srcFile = try AVAudioFile(forReading: src)
let dstFile = try AVAudioFile(forWriting: dst, settings: srcFile.fileFormat.settings, commonFormat: srcFile.processingFormat.commonFormat, interleaved: srcFile.processingFormat.isInterleaved)


let frameCount = AVAudioFrameCount(srcFile.length)
let channelCount = srcFile.fileFormat.channelCount

guard let buffer = AVAudioPCMBuffer(pcmFormat: srcFile.processingFormat, frameCapacity: frameCount)
    else {
        fatalError("Derp")
}

try srcFile.read(into: buffer, frameCount: frameCount)

for i in 0...frameCount*channelCount {
    if(abs(buffer.floatChannelData!.pointee[Int(i)])>normFac) {
        normFac = abs(buffer.floatChannelData!.pointee[Int(i)])
    }
}

for i in 0...frameCount*channelCount {
    buffer.floatChannelData!.pointee[Int(i)] = buffer.floatChannelData!.pointee[Int(i)] * 1.0/normFac
}

try dstFile.write(from: buffer)
