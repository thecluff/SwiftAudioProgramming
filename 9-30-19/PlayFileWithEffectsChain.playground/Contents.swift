import Cocoa
import Foundation
import AVFoundation

let fileNameWithPath = "/Users/charliecluff/Desktop/MiscProgramming/1.wav"

let engine = AVAudioEngine()

var outputNode: AVAudioOutputNode!
outputNode = engine.outputNode

let mixerNode = AVAudioMixerNode()

let playerNode = AVAudioPlayerNode()

//: Add an EQ processor
let eqNode = AVAudioUnitEQ.init(numberOfBands: 2)
var filterParams = eqNode.bands[0] as AVAudioUnitEQFilterParameters
filterParams.filterType = .bandPass
filterParams.frequency = 5000.0
filterParams.bandwidth = 1.0
filterParams.bypass = false
filterParams.gain = 4.0

//: Add a Delay processor
let delayNode = AVAudioUnitDelay()
delayNode.wetDryMix = 75
delayNode.lowPassCutoff = 10000
delayNode.feedback = 60
delayNode.delayTime = 10

//: Node settings
let distortionNode = AVAudioUnitDistortion()
distortionNode.preGain = 1.0
distortionNode.wetDryMix = 50

//: Connect nodes to build a signal path
engine.attach(mixerNode)
engine.attach(eqNode)
engine.attach(delayNode)
engine.attach(distortionNode)
engine.attach(playerNode)
engine.connect(playerNode, to: eqNode, format: nil)
engine.connect(eqNode, to: delayNode, format: nil)
engine.connect(delayNode, to: distortionNode, format: nil)
engine.connect(distortionNode, to: mixerNode, format: nil)
engine.connect(mixerNode, to: outputNode, format: nil)
//
//engine.connect(playerNode, to: engine.mainMixerNode, format: nil)

engine.prepare()

do {
    let url = URL(fileURLWithPath: fileNameWithPath)
    let file = try AVAudioFile(forReading: url)
    playerNode.scheduleFile(file, at: nil, completionHandler: nil)
    print("Audio file scheduled")
} catch {
    print("Failed to read file: \(error.localizedDescription)")
}
do {
    try engine.start()
    print("Engine started")
    playerNode.play()
    sleep(1)
} catch {
    print("Failed to start engine: \(error.localizedDescription)")
}
