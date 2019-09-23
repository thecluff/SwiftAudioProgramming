//: # Capture Audio
//: Allow the input of audio from the built in microphone or some other real-time source
//: Normally the real-time capture would be implemented from within a GUI which would allow
//: the user to start and stop at will.
//: However, we can implement capture without a GUI to keep the capture loop open and stop when the user decides.

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
//: Connect nodes to build a signal path
engine.attach(mixerNode)
engine.connect(inputNode, to: mixerNode, format: nil)
engine.connect(mixerNode, to: outputNode, format: nil)
mixerNode.volume = 0.5
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
