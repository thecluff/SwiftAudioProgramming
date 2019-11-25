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

    @IBAction func sayRBClicked(_ sender: Any) {
        if Gain.state.rawValue == 1 {
            selection = 1
        } else if
            Normalize.state.rawValue == 1 {
            selection = 2
        } else if
            Reverse.state.rawValue == 1 {
            print("Reverse")
        } else {
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
                default:
                    print("")
                }
            }
        } else {
            return
        }
    }
    
    
    
}

