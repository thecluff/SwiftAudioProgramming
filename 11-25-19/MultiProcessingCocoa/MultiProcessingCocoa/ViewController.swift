//
//  ViewController.swift
//  MultiProcessingCocoa
//
//  Created by Charlie Cluff on 11/25/19.
//  Copyright © 2019 Charlie Cluff. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {
    
    @IBOutlet weak var Param1: NSTextField!
    @IBOutlet weak var Gain: NSButton!
    @IBOutlet weak var Normalize: NSButton!
    @IBOutlet weak var Reverse: NSButton!
    @IBOutlet weak var Rectify: NSButton!
    @IBOutlet weak var Invert: NSButton!
    @IBOutlet weak var Clip: NSButton!
    @IBOutlet weak var Extortion: NSButton!
    @IBOutlet weak var FadeIn: NSButton!
    @IBOutlet weak var FadeOut: NSButton!
    @IBOutlet weak var AmpMod: NSButton!
    @IBOutlet weak var VarAmpMod: NSButton!
    @IBOutlet weak var Waveshape: NSButton!
    @IBOutlet weak var PanMod: NSButton!
    
    var fileNameWithPath = ""
    
    // Create space for the application
    var normFac: Float = 0.0
    var gainFac: Float = 1.0
    var clipValue: Float = 1.0
    var selection: Int = 1
    var param1: Float = 1.0
    var srcPath = ""
    var dstPath = ""
    
    var frameCount: AVAudioFrameCount = 0
    var channelCount: UInt32 = 2
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func sayProcessClicked(_ sender: Any) {
        print("Processed clicked")
        let src = URL(fileURLWithPath: srcPath)
        let dst = URL(fileURLWithPath: dstPath)
        
        let srcFile = try! AVAudioFile(forReading: src)
        let dstFile = try! AVAudioFile(forWriting: dst, settings: srcFile.fileFormat.settings, commonFormat: srcFile.processingFormat.commonFormat, interleaved: srcFile.processingFormat.isInterleaved)
        
        let frameCount = AVAudioFrameCount(srcFile.length)
        print(frameCount)
        let channelCount = srcFile.fileFormat.channelCount
        print(channelCount)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: srcFile.processingFormat, frameCapacity: frameCount)
            else {
                fatalError("Derp")
        }
        try! srcFile.read(into: buffer, frameCount: frameCount)
        
        switch selection {
        case 1:
            // Gain
            print("Now performing gain \n")
            gainFac = param1
            for i in 0..<frameCount*channelCount {
                buffer.floatChannelData!.pointee[Int(i)] =  buffer.floatChannelData!.pointee[Int(i)] * gainFac
            }
        case 2:
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
        case 3:
            // Rectification
            print("Now performing rectification")
            for i in 0..<frameCount*channelCount {
                if(buffer.floatChannelData!.pointee[Int(i)]<0) { // Check polarity
                    buffer.floatChannelData!.pointee[Int(i)] = buffer.floatChannelData!.pointee[Int(i)] * -1.0
                } else {
                    buffer.floatChannelData!.pointee[Int(i)] = buffer.floatChannelData!.pointee[Int(i)]
                }
            }
        case 4:
            // Inversion
            print("Now performing inversion")
            for i in 0..<frameCount*channelCount {
                buffer.floatChannelData!.pointee[Int(i)] = buffer.floatChannelData!.pointee[Int(i)] * -1.0
            }
        case 5:
            // Clipping
            print("Now performing clipping")
            var clipValue = param1
            for i in 0..<frameCount*channelCount {
                if(buffer.floatChannelData!.pointee[Int(i)]>clipValue) {
                    buffer.floatChannelData!.pointee[Int(i)] = buffer.floatChannelData!.pointee[Int(i)] * clipValue
                }
            }
        case 6:
            // Extortion
            print("Now performing extortion \n")
            var extValue = param1
            for i in 0..<frameCount*channelCount {
                buffer.floatChannelData!.pointee[Int(i)] = buffer.floatChannelData!.pointee[Int(i)] * 50
            }
            for i in 0..<frameCount*channelCount {
                if(buffer.floatChannelData!.pointee[Int(i)] > extValue) { // Check polarity
                    buffer.floatChannelData!.pointee[Int(i)] = buffer.floatChannelData!.pointee[Int(i)] * extValue
                }
            }
        case 7:
            // Fade In
            print("Now performing Fade In \n")
            // Convert the fade in time to number of samples
            var fadeTime = param1
            let nSamps = Int(Float(srcFile.fileFormat.sampleRate) * Float(channelCount) * Float(fadeTime))
            
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
            // Fade Out
            print("Now performing Fade Out \n")
            var FadeOutTime = param1
            let nSamps = Int(Float(srcFile.fileFormat.sampleRate) * Float(channelCount) * Float(FadeOutTime))
            
            if (channelCount==2) {
                for i in 0..<nSamps {
                    buffer.floatChannelData!.pointee[Int(i) - 1 - Int(i)] *= (Float(i) / Float(nSamps))
                    buffer.floatChannelData!.pointee[(Int(frameCount) * 2) - 1 - Int(i)+Int(frameCount)] *= (Float(i))
                }
            } else {
                for i in 0..<nSamps {
                    buffer.floatChannelData!.pointee[Int(frameCount) - 1 - Int(i)] *= (Float(i) / Float(nSamps))
                }
            }
        case 9:
            // Amplitude Modulation
            print("Now performing Amplitude Modulation \n")
            let amp: Float = 1.0
            let freq: Float = param1
            let phase: Float = 0.0
            var tr: Float = 0.0
            // Check for stereo
            if (channelCount==2) {
                for i in 0..<frameCount {
                tr = amp * sin(freq*Float(i)*2.0*Float.pi/Float(srcFile.fileFormat.sampleRate)+phase)
                buffer.floatChannelData!.pointee[Int(frameCount) - 1 - Int(i)] *= Float(tr)
                buffer.floatChannelData!.pointee[Int(frameCount * 2) - 1 - Int(i)] *= Float(tr)
                }
            } else {
                for i in 0..<frameCount {
                    tr = amp * sin(freq*Float(i)*2.0*Float.pi/Float(srcFile.fileFormat.sampleRate)+phase)
                    buffer.floatChannelData!.pointee[Int(frameCount) - 1 - Int(i)] *= Float(tr)
                }
            }
        case 10:
            // Variable Amplitude modulation
            print("Now performing Variable Amplitude Modulation \n")
            let amp: Float = 1.0
            var freq: Float = param1
            let phase: Float = 0.0
            var tr: Float = 0.0
            var lfo: Float = 0.0
            // Generate a sinewave and multiply each sample of the source by a sine wave sample value
            if (channelCount==2) {
                for i in 0..<frameCount {
                    lfo = freq * Float(i)/Float(frameCount)
                    tr = amp * sin(lfo*Float(i)*2.0*Float.pi/Float(srcFile.fileFormat.sampleRate)+phase)
                    buffer.floatChannelData!.pointee[Int(i)] *= Float(tr)
                    buffer.floatChannelData!.pointee[Int(i)+Int(frameCount)] *= Float(tr)
                }
            } else {
                for i in 0..<frameCount {
                    lfo = freq * Float(i)/Float(frameCount)
                    tr = amp * sin(lfo*Float(i)*2.0*Float.pi/Float(srcFile.fileFormat.sampleRate)+phase)
                    buffer.floatChannelData!.pointee[Int(i)] *= Float(tr)
                }
            }
        case 11:
            // Waveshaper
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
            
            let amp: Float = 1.0
            let freq: Float = param1
            let phase: Float = 0.0
            var tr: Float = 0.0
            var lfo: Float = 0.0
            let accelerate: Float = 1.0 // Change to param2
            
            // Check for stereo
            if(channelCount==2) {
                for i in 0..<frameCount {
                    if (accelerate == 1){
                        lfo = freq * Float(i)/Float(frameCount)
                    } else {
                        lfo = freq
                    }
                    
                    tr = 1.0 + (amp * sin(lfo*Float(i)*2.0*Float.pi/Float(srcFile.fileFormat.sampleRate)+phase))
                    buffer.floatChannelData!.pointee[Int(i)] *= Float(tr)
                    buffer.floatChannelData!.pointee[Int(i)+Int(frameCount)] *= Float(1.0-tr)
                }
            } else {
                // Do nothing
            }
            
            
        default:
            print("Now performing.. ")
        }
        // Now write the buffer to file
        try! dstFile.write(from: buffer)
        print("Done")
        
    }
    
    @IBAction func sayTextEntered(_ sender: Any) {
        param1 = Float(Param1.stringValue) ?? 0.0
    }
    //    @IBAction func Param2(_ sender: Any) {
    //        param2 = Float(Param2.stringValue) ?? 0.0
    //    }
    
    @IBAction func sayRBClicked(_ sender: Any) {
        if Gain.state.rawValue == 1 {
            selection = 1
        } else if
            Normalize.state.rawValue == 1 {
            selection = 2
        } else if
            Rectify.state.rawValue == 1 {
            selection = 3
        } else if
            Invert.state.rawValue == 1 {
            selection = 4
        } else if
            Clip.state.rawValue == 1 {
            selection = 5
        } else if
            Extortion.state.rawValue == 1 {
            selection = 6
        } else if
            FadeIn.state.rawValue == 1 {
            selection = 7
        } else if
            FadeOut.state.rawValue == 1 {
            selection = 8
        } else if
            AmpMod.state.rawValue == 1 {
            selection = 9
        } else if
            VarAmpMod.state.rawValue == 1 {
            selection = 10
        } else if
            Waveshape.state.rawValue == 1 {
            selection = 11
        } else if
            Reverse.state.rawValue == 1 {
            selection = 12
        } else if
            PanMod.state.rawValue == 1 {
            selection = 13
        }
        else {
            // Nothing
        }
    }
    
    
    @IBAction func browseInputFile(_ sender: Any) {
        let dialog = NSOpenPanel()
        
        dialog.title = "Audio File Selection"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseDirectories = true
        dialog.canCreateDirectories = true
        dialog.canChooseFiles = true
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes = nil
        
        if(dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url
            
            if (result != nil) {
                let path = result!.path
                let index = path.firstIndex(of: ".") ?? path.endIndex
                let outFile = path[..<index]
                srcPath = path
                switch selection {
                case 1:
                    dstPath = outFile + "Gain.caf"
                case 2:
                    dstPath = outFile + "Norm.caf"
                case 3:
                    dstPath = outFile + "Rectified.caf"
                case 4:
                    dstPath = outFile + "Inverted.caf"
                case 5:
                    dstPath = outFile + "Clipped.caf"
                case 6:
                    dstPath = outFile + "Extorted.caf"
                case 7:
                    dstPath = outFile + "FadedIn.caf"
                case 8:
                    dstPath = outFile + "FadedOut.caf"
                case 9:
                    dstPath = outFile + "AmpMod.caf"
                case 10:
                    dstPath = outFile + "VarAmpMod.caf"
                case 11:
                    dstPath = outFile + "Waveshaped.caf"
                case 12:
                    dstPath = outFile + "Reversed.caf"
                case 13:
                    dstPath = outFile + "PanMod.caf"
                default:
                    print("")
                }
            }
        } else {
            return
        }
    }
}

