//: # Read -> Write Audio
//: Transfer audio content from one file to another, in order to learn mechanics of audio file I/O.

import Cocoa
import AVFoundation

let src = URL(fileURLWithPath: "/Users/charliecluff/Desktop/SwiftAudioProgramming/SwiftAudioProgramming/exampleAudio/2FistedMama-Fade.wav")
let dst = URL(fileURLWithPath: "/Users/charliecluff/Desktop/SwiftAudioProgramming/SwiftAudioProgramming/exampleAudio/2FistedMama-Fade.caf")

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
try dstFile.write(from: buffer)
