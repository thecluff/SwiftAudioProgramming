import Cocoa
import Foundation
import AVFoundation

let fileNameWithPath = "/Users/charliecluff/Desktop/SwiftAudioProgramming/SwiftAudioProgramming/9-23-19/Fahrenheit451Prelude-Fade.wav"

//: Build audio playback chain and file input
let engine = AVAudioEngine()
//: Add audio processing nodes
let playerNode = AVAudioPlayerNode()

//: Attach the node to the engine
engine.attach(playerNode)

engine.connect(playerNode, to: engine.mainMixerNode, format: nil)

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
