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

let noteArray: [UInt8] = [0, 12, 9, 10]

var packetArray = [MIDIPacket]()

// The sequence length needs to be even
let sequenceLength = noteArray.count * 2

for n in 0..<sequenceLength {
    packetArray.append(MIDIPacket())
    packetArray[n].timeStamp = 0
    packetArray[n].length = 3
    packetArray[n].data.0 = 0x90

    if n%2 == 0 {
        packetArray[n].data.1 = UInt8(0x3c + noteArray[n/2])
        packetArray[n].data.2 = 0x4B
        } else {
        packetArray[n].data.1 = UInt8(0x3c + noteArray[n/2])
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
    sleep(1);
    packetList = MIDIPacketList(numPackets: 1, packet: packetArray[n*2+1]);
    MIDISend(outPort, dest, &packetList);
    sleep(1)
}
print("Note off sent")

// A packet is just a way of thinking about multiple bytes as a single thing
// Program a song using all of this
