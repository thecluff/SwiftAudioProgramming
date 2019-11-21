//
//  main.swift
//  MixProjectRevisited
//
//  Created by Charlie Cluff on 11/13/19.
//  Copyright © 2019 Charlie Cluff. All rights reserved.
//

import Foundation
import AVFoundation

// Test for command line arguments
if(CommandLine.argc<4){
    print("Execution: AudioFileMixing src1 src2 dst offset")
    exit(1)
}

let srcPath1 = CommandLine.arguments[1]
let srcPath2 = CommandLine.arguments[2]
let dstPath = CommandLine.arguments[3]
let offsetInSec = Double(CommandLine.arguments[4]) // The offset is in seconds and will need to be converted into frames.

let src1 = URL(fileURLWithPath: srcPath1)
let src2 = URL(fileURLWithPath: srcPath2)
let dst = URL(fileURLWithPath: dstPath)

let srcFile1 = try AVAudioFile(forReading: src1)
let srcFile2 = try AVAudioFile(forReading: src2)

let frameCount1 = AVAudioFrameCount(srcFile1.length)
let channelCount1 = srcFile1.fileFormat.channelCount

guard let buffer1 = AVAudioPCMBuffer(pcmFormat: srcFile1.processingFormat, frameCapacity: frameCount1)
    else {
        fatalError("Input buffer 1 could not be allocated.")
}
try srcFile1.read(into: buffer1, frameCount: frameCount1)

let frameCount2 = AVAudioFrameCount(srcFile2.length)
let channelCount2 = srcFile2.fileFormat.channelCount

guard let buffer2 = AVAudioPCMBuffer(pcmFormat: srcFile2.processingFormat, frameCapacity: frameCount2)
    else {
        fatalError("Derp")
}
try srcFile2.read(into: buffer2, frameCount: frameCount2)

if(srcFile1.processingFormat.sampleRate != srcFile2.processingFormat.sampleRate) {
    print("Input buffer 2 could not be allocated.")
    exit(1)
}

//if(srcFile1.fileFormat.channelCount != srcFile2.fileFormat.channelCount) {
//    print("Both files need to have the same number of channels, homie.")
//    exit(1)
//}

let offsetInFrames = Int(offsetInSec! * srcFile1.processingFormat.sampleRate)
// Set the mix frame count based on either the length of srcFile1 or that of srcFile2 + offset
let mixFrameCount = (AVAudioFrameCount(srcFile1.length)>(AVAudioFrameCount(srcFile2.length)+UInt32(offsetInFrames)) ? AVAudioFrameCount(srcFile1.length) : AVAudioFrameCount(srcFile2.length)+UInt32(offsetInFrames))

var mixBuffer = Array(repeating: Float(0.0), count: Int(mixFrameCount*srcFile1.fileFormat.channelCount))

// Copy audio samples into the mix buffer
for i in 0..<frameCount1 {
    mixBuffer[Int(i)*2] = buffer1.floatChannelData!.pointee[Int(i)]
    if(i>0) {
    mixBuffer[Int(i)*2-1] = buffer1.floatChannelData!.pointee[Int(i)+Int(frameCount1)]
    }
}

for i in offsetInFrames*Int(srcFile1.fileFormat.channelCount)..<Int(mixFrameCount*srcFile1.fileFormat.channelCount) {
    mixBuffer[Int(i)*2] = mixBuffer[Int(i)*2] + buffer2.floatChannelData!.pointee[i-offsetInFrames*Int(srcFile1.fileFormat.channelCount)]
    if(i>0) {
       mixBuffer[Int(i)*2-1] = mixBuffer[Int(i)*2-1] + buffer2.floatChannelData!.pointee[i-offsetInFrames*Int(srcFile1.fileFormat.channelCount)+Int(frameCount1)]
    }
}

let dstFile = try AVAudioFile(forWriting: dst, settings: srcFile1.fileFormat.settings, commonFormat: srcFile1.processingFormat.commonFormat, interleaved: srcFile1.processingFormat.isInterleaved)

guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: srcFile2.processingFormat, frameCapacity: mixFrameCount)
    else {
        fatalError("Output buffer could not be allocated.")
}

// Copy audio samples from the mix buffer to the output buffer
for i in 0..<mixFrameCount*srcFile1.fileFormat.channelCount{
    outputBuffer.floatChannelData!.pointee[Int(i)] = mixBuffer[1]
}

try dstFile.write(from: outputBuffer)
