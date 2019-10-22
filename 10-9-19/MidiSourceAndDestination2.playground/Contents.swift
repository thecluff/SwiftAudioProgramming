//: # This playground generates tones in the egyptian scale.
//: ## I recorded a random series of tones using this program for each basic waveshape using a Pd patch I made via Soundflower.
//: ## Then, I lined up each recording using Logic, which resulted in interesting chords.
//: Some of the chords were a litte dissonant, so I chopped up the chords and left out the less favorable ones.
//: Then, I arranged each chord into a nice sounding progression. I then used a couple other Pd patches (inlcuded in the .zip file) to generate other tones using this program.
//: I added some effects using another Swift program (also included in the .zip file) to the second set of sounds I made, mainly delay and distortion.
//: Then, I arranged all of the sounds using Logic Pro X, and then saved the end result as ./Swifty.wav (44100 24bit PCM)

import Cocoa
import CoreMIDI
import PlaygroundSupport

func getDisplayName(_ obj: MIDIObjectRef) -> String
{
    var param: Unmanaged<CFString>?
    var name: String = "Error";
    let err: OSStatus = MIDIObjectGetStringProperty(obj, kMIDIPropertyDisplayName, &param)
    if err == OSStatus(noErr)
    {
        name =  param!.takeRetainedValue() as String
    }
    return name;
}

func getDestinationNames() -> [String]
{
    var names:[String] = [String]();
    
    let count: Int = MIDIGetNumberOfDestinations();
    for i in 0 ..< count
    {
        let endpoint:MIDIEndpointRef = MIDIGetDestination(i);
        if (endpoint != 0)
        {
            names.append(getDisplayName(endpoint));
        }
    }
    return names;
}

var midiClient: MIDIClientRef = 0;
var outPort:MIDIPortRef = 0;

MIDIClientCreate("MidiTestClient" as CFString, nil, nil, &midiClient);
MIDIOutputPortCreate(midiClient, "MidiTest_OutPort" as CFString, &outPort);

// The sequence length needs to be even
let sequenceLength = 24

let noteArray: [UInt8] = [0, 2, 4, 5, 7, 9, 11]

var packetArray = [MIDIPacket]()

var x = 0

for n in 0..<sequenceLength {
    packetArray.append(MIDIPacket())
    packetArray[n].timeStamp = 0
    packetArray[n].length = 3
    packetArray[n].data.0 = 0x90

    if n%2 == 0 {
        x = Int.random(in:0...7)
        packetArray[n].data.1 = UInt8(0x3c + noteArray[x])
        packetArray[n].data.2 = 0x4B
        } else {
        packetArray[n].data.1 = UInt8(0x3c + noteArray[x])
        packetArray[n].data.2 = 0
        }
}

var packetList:MIDIPacketList = MIDIPacketList(numPackets: 20, packet: packetArray[0]);

let destinationNames = getDestinationNames()
for (index,destName) in destinationNames.enumerated()
{
    print("Destination #\(index): \(destName)")
}

let destNum = 0
print("Using destination #\(destNum)")

var dest:MIDIEndpointRef = MIDIGetDestination(destNum);
print("Playing note for 1 second on channel 1")
for n in 0..<sequenceLength/2 {
    packetList = MIDIPacketList(numPackets: 1, packet: packetArray[n*2]);
    MIDISend(outPort, dest, &packetList);
//    print(packetList)
    sleep(1);
    packetList = MIDIPacketList(numPackets: 1, packet: packetArray[n*2+1]);
    MIDISend(outPort, dest, &packetList);
    sleep(1)
}
print("Note off sent")

// A packet is just a way of thinking about multiple bytes as a single thing
// Program a song using all of this
