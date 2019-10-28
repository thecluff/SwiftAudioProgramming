//
//  main.swift
//  StereoToMono
//
//  Created by Charlie Cluff on 10/28/19.
//  Copyright © 2019 Charlie Cluff. All rights reserved.
//

import Foundation
import AVFoundation

let src = URL(fileURLWithPath: "/Users/charliecluff/Desktop/SwiftAudioProgramming/SwiftAudioProgramming/exampleAudio/DillaOrganStereo.wav")

let dst = URL(fileURLWithPath: "/Users/charliecluff/Desktop/SwiftAudioProgramming/SwiftAudioProgramming/10-28-19/DillaOrganStereoToMono.caf")

let srcFile = try AVAudioFile(forReading: src)

let channelCount = srcFile.fileFormat.channelCount
// Test the file to see if it is stereo

if (channelCount != 2){
    print("Input file has \(channelCount) channels")
    exit(1)
}

let fileFormat = srcFile.fileFormat
// Declare frame count and sample rate
let frameCount = AVAudioFrameCount(srcFile.length)
print("The number of frames is \(frameCount)")
let sampleRate = srcFile.fileFormat.sampleRate

// Set the output format settings by hand
let outputFormatSettings = [
    AVFormatIDKey: kAudioFormatLinearPCM,
    AVLinearPCMBitDepthKey: 32,
    AVLinearPCMIsFloatKey: true,
    AVSampleRateKey: sampleRate,
    AVNumberOfChannelsKey: 1
    ] as [String: Any]

// Set up destination file
let dstFile = try? AVAudioFile(forWriting: dst, settings: outputFormatSettings, commonFormat: AVAudioCommonFormat.pcmFormatFloat32, interleaved: true)

guard let buffer = AVAudioPCMBuffer(pcmFormat: srcFile.processingFormat, frameCapacity: frameCount)
    else { fatalError("Input file cannot be read, my dawg.")}

let bufferFormat = AVAudioFormat(settings: outputFormatSettings)

let outputBuffer = AVAudioPCMBuffer(pcmFormat: bufferFormat!, frameCapacity: AVAudioFrameCount(frameCount))

// Read audio samples from disk into memory
try srcFile.read(into: buffer, frameCount: frameCount)

// Copy samples and consolidate channels
for i in 0..<frameCount {
    outputBuffer?.floatChannelData!.pointee[Int(i)] = (buffer.floatChannelData!.pointee[Int(i)] + buffer.floatChannelData!.pointee[Int(i) + Int(frameCount)]) / 2.0
}
// Operator precedence = division higher precedence than division
outputBuffer!.frameLength = AVAudioFrameCount(frameCount)

print("The number of output frames is \(outputBuffer?.frameCapacity as Any).")

// Pull the trigger
do {
    try dstFile?.write(from:outputBuffer!)
} catch let error as NSError {
    print("Error: ", error.localizedDescription)
}
