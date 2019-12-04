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

var selection = Int(CommandLine.arguments[3])
var normFac: Float = 0.0
var gainFac: Float = 1.5
var clipValue: Float = 1.0

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
print("\t1. Normalization\n")
print("\t2. Gain gainFac\n")
print("\t3. Rectification\n")
print("\t4. Inversion\n")
print("\t5. Clip clipValue\n")
print("\t7. Fade In\n")
print("\t8. Fade Out\n")
print("\t9. Amplitude Modulation\n")
print("\t10. Variable Amplitude Modulation\n")
print("\t11. Waveshaper\n")
print("\t12. Reverse\n")
print("\t13. Pan Modulation\n")
print("\t14. Biquad filter\n")

//: Loop through the buffer and change the amplitudes of the samples by a constant factor. (i.e., gain)
//: When the samples are in the audio files, they are interleaved. They are read into the buffer de-interleaved.
//: In other words, all the samples in one channel are contiguous, followed by all of the samples from the other channel.

switch selection {
    
case 1:
    // Normalization
    print("Now performing normalization \n")
    for i in 0..<frameCount*channelCount {
        if(abs(buffer.floatChannelData!.pointee[Int(i)])>normFac) {
            normFac = abs(buffer.floatChannelData!.pointee[Int(i)])
        }
    }
    // Scale gain to 1.0
    for i in 0..<frameCount*channelCount {
        buffer.floatChannelData!.pointee[Int(i)] = buffer.floatChannelData!.pointee[Int(i)] * 1.0/normFac
    }
case 2:
    // Gain
    print("Now performing gain \n")
    gainFac = Float(CommandLine.arguments[4])!
    for i in 0..<frameCount*channelCount {
        buffer.floatChannelData!.pointee[Int(i)] =  buffer.floatChannelData!.pointee[Int(i)] * gainFac
    }
case 3:
    // Rectification
    print("Now performing rectification \n")
    for i in 0..<frameCount*channelCount{
        if(buffer.floatChannelData!.pointee[Int(i)]<0) { // Check polarity
            buffer.floatChannelData!.pointee[Int(i)] = buffer.floatChannelData!.pointee[Int(i)] * -1.0
            // If below 0, multiply by -1
        }else {
            buffer.floatChannelData!.pointee[Int(i)] =
                buffer.floatChannelData!.pointee[Int(i)]
        }
    }
case 4:
    // Inversion
    print("Now performing inversion \n")
    for i in 0..<frameCount*channelCount {
            buffer.floatChannelData!.pointee[Int(i)] = buffer.floatChannelData!.pointee[Int(i)] * -1.0
    }
case 5:
    // Clipping
    print("Now performing clipping \n")
    clipValue = Float(CommandLine.arguments[4])!
    for i in 0..<frameCount*channelCount {
        if(buffer.floatChannelData!.pointee[Int(i)]>clipValue) {
            buffer.floatChannelData!.pointee[Int(i)] = buffer.floatChannelData!.pointee[Int(i)] * clipValue
        }
    }
case 6:
    // "Extortion" - Extreme distortion
    s
    clipValue = Float(CommandLine.arguments[4])!
    for i in 0..<frameCount*channelCount {
        buffer.floatChannelData!.pointee[Int(i)] =  buffer.floatChannelData!.pointee[Int(i)] * 50
    }
    for i in 0..<frameCount*channelCount {
        if(buffer.floatChannelData!.pointee[Int(i)] > clipValue) { // Check polarity
            buffer.floatChannelData!.pointee[Int(i)] = buffer.floatChannelData!.pointee[Int(i)] * clipValue
        }
    }
case 7:
    // Fade in - needs copy buffer, fade length/time, number of channels, and sample rate
    print("Now performing fade in \n")
    // Convert fade in time to number of samples
    // Capture the fade in time from command line
    let fadeInTime = Double(CommandLine.arguments[4])!
    let nSamps = Int(srcFile.fileFormat.sampleRate * Double(channelCount) * fadeInTime)
    
    // Check for stereo
    if (channelCount==2) {
        for i in 0..<nSamps {
            buffer.floatChannelData!.pointee[Int(i)] *= (Float(i) / Float(nSamps))
            buffer.floatChannelData!.pointee[Int(i+Int(frameCount))] *= (Float(i) / Float(nSamps))
        }
    } else {
        for i in 0..<nSamps {
            buffer.floatChannelData!.pointee[Int(i)] *= (Float(i) / Float(nSamps))
        }
    }
case 8:
    // Fade out - needs copy buffer, fade length/time, number of channels, and sample rate
    print("Now performing fade out \n")
    // Convert fade out time to number of samples
    // Capture the fade out time from command line
    let fadeInTime = Double(CommandLine.arguments[4])!
    let nSamps = Int(srcFile.fileFormat.sampleRate * Double(channelCount) * fadeInTime)
    
    // Check for stereo
    if (channelCount==2) {
        for i in 0..<nSamps {
            buffer.floatChannelData!.pointee[Int(frameCount) - 1 - Int(i)] *= (Float(i) / Float(nSamps))
            buffer.floatChannelData!.pointee[(Int(frameCount) * 2) - 1 - Int(i)+Int(frameCount)] *= (Float(i) / Float(nSamps))
        }
    } else {
        for i in 0..<nSamps {
            buffer.floatChannelData!.pointee[Int(frameCount) - 1 - Int(i)] *= (Float(i) / Float(nSamps))
        }
    }
case 9:
    // Amplitude Modulation - needs frequency, sample rate
    print("Now performing amplitude modulation \n")
    let amp = 1.0
    let freq = Double(CommandLine.arguments[4])!
    let phase = 0.0
    var tr = 0.0
    // Generate a sine wave and multiply each sample of the source by a sine wave sample value
    
    // Check for stereo
    if (channelCount==2) {
        for i in 0..<frameCount {
            tr = amp * sin(freq*Double(i)*2.0*Double.pi/srcFile.fileFormat.sampleRate+phase)
            buffer.floatChannelData!.pointee[Int(frameCount) - 1 - Int(i)] *= Float(tr)
            buffer.floatChannelData!.pointee[Int(frameCount * 2) - 1 - Int(i)] *= Float(tr)
        }
    } else {
        for i in 0..<frameCount {
            tr = amp * sin(freq*Double(i)*2.0*Double.pi/srcFile.fileFormat.sampleRate+phase)
            buffer.floatChannelData!.pointee[Int(frameCount) - 1 - Int(i)] *= Float(tr)
        }
    }
case 10:
    // Variable Amplitude Modulation - needs frequency, sample rate
    print("Now performing variable amplitude modulation \n")
    let amp = 1.0
    let freq = Double(CommandLine.arguments[4])!
    let phase = 0.0
    var tr = 0.0
    var lfo = 0.0
    // Generate a sine wave and multiply each sample of the source by a sine wave sample value
    
    // Check for stereo
    if (channelCount==2) {
        for i in 0..<frameCount {
            lfo = freq * Double(i)/Double(frameCount)
            tr = amp * sin(lfo*Double(i)*2.0*Double.pi/srcFile.fileFormat.sampleRate+phase)
            buffer.floatChannelData!.pointee[Int(i)] *= Float(tr)
            buffer.floatChannelData!.pointee[Int(i)+Int(frameCount)] *= Float(tr)
        }
    } else {
        for i in 0..<frameCount {
            lfo = freq * Double(i)/Double(frameCount)
            tr = amp * sin(lfo*Double(i)*2.0*Double.pi/srcFile.fileFormat.sampleRate+phase)
            buffer.floatChannelData!.pointee[Int(i)] *= Float(tr)
        }
    }
case 11:
    // Simple tangent waveshaper a la Will Pirkle
    // Needs two distortion factors
    print("Now performing waveshaping")
    let tableSize = 2048
    var tempBuf = Array(repeating: Float(0.0), count: Int(tableSize))
    var index1: Int = 0
    var index2: Int = 0
    
    for i in 0..<tableSize {
        tempBuf[Int(i)] = pow((Float(i) / Float(tableSize) * 2.0) - 1.0, 3.0)
    }
    
    if (channelCount==2) {
        for i in 0..<frameCount {
            index1 = Int((buffer.floatChannelData!.pointee[Int(i)] / 2.0 + 0.5) * Float(tableSize))
                index2 = Int((buffer.floatChannelData!.pointee[Int(i)+Int(frameCount)] / 2.0 + 0.5) * Float(tableSize))
                buffer.floatChannelData!.pointee[Int(i)] = tempBuf[index1]
                buffer.floatChannelData!.pointee[Int(i)+Int(frameCount)] = tempBuf[index2]
        }
    } else {
        for i in 0..<frameCount {
            index1 = Int((buffer.floatChannelData!.pointee[Int(i)] / 2.0 + 0.5) * Float(tableSize))
                buffer.floatChannelData!.pointee[Int(i)] = tempBuf[index1]
        }
    }
    
case 12:
    // Reverse
    // Reverse requires a temp buffer - the idea is that we copy fom the end to the beginning of the source file into the destination file in normal beginning to end direction
    print("Now Performing Reverse")
    
    // Declare a copy buffer
    var tempBuf = Array(repeating: Float(0.0), count: Int(frameCount*channelCount))
    
    // Copy from the main buffer to temp buffer
    for i in stride(from: 0, to: frameCount*channelCount, by: 1) {
        tempBuf[Int(frameCount*channelCount-1-i)] = buffer.floatChannelData!.pointee[Int(i)]
    }
    
    for i in stride(from: 0, to: frameCount*channelCount, by: 1) {
        buffer.floatChannelData!.pointee[Int(i)] = tempBuf[Int(i)]
    }

case 13:
    // Pan modulation
    // This will cause a signal to fluctuate its position in the stereo field in response to a sinwave oscillator
    print("Now performing pan modulation \n")
    
    let amp = 1.0
    let freq = Double(CommandLine.arguments[4])!
    let phase = 0.0
    var tr = 0.0
    var lfo = 0.0
    let accelerate = Double(CommandLine.arguments[5])!
    
    // Check for stereo
    if(channelCount==2) {
        for i in 0..<frameCount {
            if (accelerate == 1){
                lfo = freq * Double(i)/Double(frameCount)
            } else {
                lfo = freq
                }
            
            tr = 1.0 + (amp * sin(lfo*Double(i)*2.0*Double.pi/srcFile.fileFormat.sampleRate+phase))
            buffer.floatChannelData!.pointee[Int(i)] *= Float(tr)
            buffer.floatChannelData!.pointee[Int(i)+Int(frameCount)] *= Float(1.0-tr)
        }
    } else {
        // Do nothing
    }
    
case 14:
    var b0: Float = 0.0
    var b1: Float = 0.0
    var b2: Float = 0.0
    var a1: Float = 0.0
    var a2: Float = 0.0
    
    // Examples:
    // Notch CF = 0.2 is 1.0 -1.61 1.0 1.46 -0.81
    // LPF is 1.0, 0.0, 0.0, 1.8, -0.81
    // HPF is 1.0, 0.0, 0.0, -1.8, -0.81
    // BPF 0.37 * NF is 1.0, 0.0, 0.0, 0.715, -0.81
    // BRF 0.75 * NF is 1.0, 1.414, 1.0, 0.0, 0.0
    // BPF 0.5 * NF is 1.0, 0.0, 0.0, 0.0, -0.81
    // BRF 0.2 * NF is 1.0, -1.61, 1.0, 1.46, -0.81
    
    switch Int(CommandLine.arguments[4]) {
    case 1:
        print("Notch at 0.2 pi")
        b0 = 1.0
        b1 = -1.61
        b2 = 1.0
        a1 = 1.46
        a2 = -0.81
    case 2:
        print("Notch at 0.75 pi")
        b0 = 1.0
        b1 = 1.414
        b2 = 1.0
        a1 = 0.0
        a2 = 0.0
    case 3:
        print("Low pass")
        b0 = 1.0
        b1 = 0.0
        b2 = 0.0
        a1 = 1.8
        a2 = -0.81
    case 4:
        print("High pass")
        b0 = 1.0
        b1 = 0.0
        b2 = 0.0
        a1 = -1.8
        a2 = -0.81
    default:
        print("Please select a case 1-5")
    }
    // Biquad filter
    print("Now performing biquad filtering \n")
    // Temp buffer
    var tempBuf = Array(repeating: Float(0.0), count: Int(frameCount*channelCount))
    // 4 filter delays
    var xn1: Float = 0.0
    var xn2: Float = 0.0
    var yn1: Float = 0.0
    var yn2: Float = 0.0
    
    // Begin to loop
    for i in stride(from: 0, to: frameCount*channelCount, by: 1){
        tempBuf[Int(i)] = buffer.floatChannelData!.pointee[Int(i)]*b0 + xn1*b1 + xn2*b2 + yn1*a1 + yn2*a2
        yn2 = yn1
        yn1 = tempBuf[Int(i)]
        xn2 = xn1
        xn1 = buffer.floatChannelData!.pointee[Int(i)]
    }
    
    // Copy samples back into main buffer
    for i in stride(from: 0, to: frameCount*channelCount, by: 1) {
        buffer.floatChannelData!.pointee[Int(i)] = tempBuf[Int(i)]
    }
    
    print("Now performing normalization \n")
    for i in 0..<frameCount*channelCount {
        if(abs(buffer.floatChannelData!.pointee[Int(i)])>normFac) {
            normFac = abs(buffer.floatChannelData!.pointee[Int(i)])
        }
    }
    // Scale gain to 1.0
    for i in 0..<frameCount*channelCount {
        buffer.floatChannelData!.pointee[Int(i)] = buffer.floatChannelData!.pointee[Int(i)] * 1.0/normFac
    }
    
    
default:
print("Now performing.. ")
}

try dstFile.write(from: buffer)
