//
//  main.swift
//  StereoToMono
//
//  Created by Charlie Cluff on 10/28/19.
//  Copyright © 2019 Charlie Cluff. All rights reserved.
//

import Foundation
import AVFoundation

let src = URL(fileURLWithPath: "/Users/charliecluff/Desktop/SwiftAudioProgramming/SwiftAudioProgramming/10-28-19/DillaOrganMono.wav")
let dst = URL(fileURLWithPath: "/Users/charliecluff/Desktop/SwiftAudioProgramming/SwiftAudioProgramming/10-28-19/DillaOrganMonoToStereo.caf")

let srcFile = try AVAudioFile(forReading: src)
let channelCount = srcFile.fileFormat.channelCount

// Test the file to see if it is stereo
if (channelCount > 1){
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
    AVNumberOfChannelsKey: 2
    ] as [String: Any]

let dstFile = try? AVAudioFile(forWriting: dst, settings: outputFormatSettings, commonFormat: AVAudioCommonFormat.pcmFormatFloat32, interleaved: true)

// Set up destination file

guard let buffer = AVAudioPCMBuffer(pcmFormat: srcFile.processingFormat, frameCapacity: frameCount)
    else { fatalError("Input samples cannot be read from the file, my dawg.")}

let bufferFormat = AVAudioFormat(settings: outputFormatSettings)
let outputBuffer = AVAudioPCMBuffer(pcmFormat: bufferFormat!, frameCapacity: AVAudioFrameCount(frameCount*2))

try srcFile.read(into: buffer, frameCount: frameCount)

for i in 0..<frameCount {
    outputBuffer?.floatChannelData!.pointee[Int(i*2)] = buffer.floatChannelData!.pointee[Int(i)]
    if(i>0) {
        outputBuffer?.floatChannelData!.pointee[Int(i*2-1)] = buffer.floatChannelData!.pointee[Int(i)]
    }
}

outputBuffer!.frameLength = AVAudioFrameCount(frameCount)

print("The number of output frames is \(outputBuffer?.frameCapacity as Any).")

// Pull the trigger
do {
    try dstFile?.write(from:outputBuffer!)
} catch let error as NSError {
    print("Error: ", error.localizedDescription)
}
