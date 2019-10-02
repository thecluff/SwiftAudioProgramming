import Cocoa
import AVFoundation

let SAMPLE_RATE = 44100.0
let duration = 0.5
let nSamples = SAMPLE_RATE * duration

let fileNameWithPath = "/Users/charliecluff/Desktop/SwiftAudioProgramming/SwiftAudioProgramming/10-2-19/sinewaveStereo.caf"
let url = URL(fileURLWithPath: fileNameWithPath)

func sinewave(sampleRate: Double, frequency: Double, amplitude: Double, nSamples: Int) -> [Double] {
    var wave = [Double]()
    for ndx in 0...nSamples {
        wave.append(amplitude * sin(2 * Double.pi * Double(ndx) * frequency / sampleRate))
    }
    return wave
}

let newSine = sinewave(sampleRate: SAMPLE_RATE, frequency: 441.0, amplitude: 1.0, nSamples: Int(nSamples))

let outputFormatSettings = [
    AVFormatIDKey: kAudioFormatLinearPCM,
    AVLinearPCMBitDepthKey: 32,
    AVLinearPCMIsFloatKey: true,
    AVSampleRateKey: SAMPLE_RATE,
    AVNumberOfChannelsKey: 2
] as [String: Any]

let audioFile = try? AVAudioFile(forWriting: url, settings: outputFormatSettings, commonFormat: AVAudioCommonFormat.pcmFormatFloat32, interleaved: true)

let bufferFormat = AVAudioFormat(settings:outputFormatSettings)
let outputBuffer = AVAudioPCMBuffer(pcmFormat: bufferFormat!, frameCapacity: AVAudioFrameCount(newSine.count*2))

for i in 0..<newSine.count {
    outputBuffer?.floatChannelData!.pointee[i*2] = Float(newSine[i])
    outputBuffer?.floatChannelData!.pointee[i*2-1] = Float(newSine[i])
}
outputBuffer!.frameLength = AVAudioFrameCount(newSine.count)

do {
    try audioFile?.write(from: outputBuffer!)
} catch let error as NSError{
    print("error:", error.localizedDescription)
}
