//
//  main.swift
//  AudioMultiProcessing
//
//  Created by Charlie Cluff on 10/23/19.
//  Copyright © 2019 Charlie Cluff. All rights reserved.
//

import Foundation
import AVFoundation

if(CommandLine.argc<4){
    print("Execution: AudioMultiProcessing src dst selection")
    exit(1)
}

//var selection: Int = 16
var selection = Int(CommandLine.arguments[3])
var normFac: Float = 0.0
var gainFac: Float = 1.5
var clipValue: Float = 0.5
let SAMPLE_RATE = 44100.0

//let srcPath = "/Users/charliecluff/Desktop/SwiftAudioProgramming/SwiftAudioProgramming/exampleAudio/JDilla_Smooth.wav"
//let dstPath = "/Users/charliecluff/Desktop/SwiftAudioProgramming/SwiftAudioProgramming/10-23-19/JDilla_Smooth_MultiProcessed.caf"
let srcPath = CommandLine.arguments[1]
let dstPath = CommandLine.arguments[2]

let src = URL(fileURLWithPath: srcPath)
let dst = URL(fileURLWithPath: dstPath)

let srcFile = try AVAudioFile(forReading: src)
let dstFile = try AVAudioFile(forWriting: dst, settings: srcFile.fileFormat.settings, commonFormat: srcFile.processingFormat.commonFormat, interleaved: srcFile.processingFormat.isInterleaved)

//: Declare the frame count
let frameCount = AVAudioFrameCount(srcFile.length)
let channelCount = srcFile.fileFormat.channelCount
guard let buffer = AVAudioPCMBuffer(pcmFormat: srcFile.processingFormat, frameCapacity: frameCount)
    else {
        fatalError("Derp")
}

//: Read, then write the audio samples from one file to another
try srcFile.read(into: buffer, frameCount: frameCount)

print("Welcome to Audio multi-processing.\n")
//print("Please choose from the following options.\n")
print("\t1. Normalization\n")
print("\t2. Gain\n")
print("\t3. Rectification\n")
print("\t4. Inversion\n")
print("\t5. Clip\n")
print("\t6. Extortion\n")

//if let input = readLine() {
//    selection = Int(input)!
//} else {
//        print("Input must be a 1-6")
//    }

switch selection {
case 1:
    print("Now performing normalization \n")
    for i in 0..<frameCount*channelCount {
        if(abs(buffer.floatChannelData!.pointee[Int(i)])>normFac) {
            normFac = abs(buffer.floatChannelData!.pointee[Int(i)])
        }
    }
    for i in 0..<frameCount*channelCount {
        buffer.floatChannelData!.pointee[Int(i)] = buffer.floatChannelData!.pointee[Int(i)] * 1.0/normFac
    }
case 2:
    print("Now performing gain \n")
    for i in 0..<frameCount*channelCount {
        buffer.floatChannelData!.pointee[Int(i)] =  buffer.floatChannelData!.pointee[Int(i)] * gainFac
    }
case 3:
    print("Now performing rectification \n")
    for i in 0..<frameCount*channelCount{
        if(buffer.floatChannelData!.pointee[Int(i)]<0) { // Check polarity
            buffer.floatChannelData!.pointee[Int(i)] = buffer.floatChannelData!.pointee[Int(i)] * -1.0
            // If below 0, multiply by -1
        }
    }
case 4:
    print("Now performing inversion \n")
    for i in 0..<frameCount*channelCount {
            buffer.floatChannelData!.pointee[Int(i)] = buffer.floatChannelData!.pointee[Int(i)] * -1.0
    }
case 5:
    print("Now performing clipping \n")
    for i in 0..<frameCount*channelCount {
        if(buffer.floatChannelData!.pointee[Int(i)]>clipValue) { // Check polarity
            buffer.floatChannelData!.pointee[Int(i)] = buffer.floatChannelData!.pointee[Int(i)] * clipValue
        }
    }
case 6:
    print("Now performing extortion \n")
    for i in 0..<frameCount*channelCount {
        buffer.floatChannelData!.pointee[Int(i)] =  buffer.floatChannelData!.pointee[Int(i)] * 50
    }
    for i in 0..<frameCount*channelCount {
        if(buffer.floatChannelData!.pointee[Int(i)] > clipValue) { // Check polarity
            buffer.floatChannelData!.pointee[Int(i)] = buffer.floatChannelData!.pointee[Int(i)] * clipValue
        }
    }
default:
    print("Now performing.. ")

}

//: Loop through the buffer and change the amplitudes of the samples by a constant factor. (i.e., gain)
//: When the samples are in the audio files, they are interleaved. They are read into the buffer de-interleaved.
//: In other words, all the samples in one channel are contiguous, followed by all of the samples from the other channel.

try dstFile.write(from: buffer)
