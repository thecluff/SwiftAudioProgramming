//: # Capture Audio
//: Allow the input of audio from the built in microphone or some other real-time source and add audio processing in the way of built-in reverb.

import Cocoa
import AVFoundation

//: The duration is how long the capture loop will stay open.
//: One possibility is to make it very long and use the playground stop button to end the capture session.
let duration: UInt32 = 60

//: Standard setup
let engine = AVAudioEngine()
//: Instantiate an input node
var inputNode: AVAudioInputNode!
inputNode = engine.inputNode
//: Send the audio stream to the output
var outputNode: AVAudioOutputNode!
outputNode = engine.outputNode
//: Add a node to control volume - with a GUI, we can control the volume level in real time.
let mixerNode = AVAudioMixerNode()

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
delayNode.wetDryMix = 50
delayNode.lowPassCutoff = 10000
delayNode.feedback = 50
delayNode.delayTime = 1000

//: Node settings
let distortionNode = AVAudioUnitDistortion()
distortionNode.preGain = 1.0
distortionNode.wetDryMix = 50

//: Connect nodes to build a signal path
engine.attach(mixerNode)
engine.attach(eqNode)
engine.attach(delayNode)
engine.attach(distortionNode)
engine.connect(inputNode, to: eqNode, format: nil)
engine.connect(eqNode, to: delayNode, format: nil)
engine.connect(delayNode, to: distortionNode, format: nil)
engine.connect(distortionNode, to: mixerNode, format: nil)
engine.connect(mixerNode, to: outputNode, format: nil)

mixerNode.volume = 0.6

//: Now for the execution
engine.prepare()
//: Start the engine, and keep our fingers crossed!

do {
    try engine.start()
    print("Engine started")
    sleep(duration)
    print("Playback complete!")
    
} catch {
    print("Failed to start audio engine: \(error.localizedDescription) ")
}

