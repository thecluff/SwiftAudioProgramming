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

var packet1:MIDIPacket = MIDIPacket();
packet1.timeStamp = 0;
packet1.length = 3;
packet1.data.0 = 0x90 + 0; // Note On event channel 1
packet1.data.1 = 0x3C; // Note C3
packet1.data.2 = 100; // Velocity

var packetList:MIDIPacketList = MIDIPacketList(numPackets: 1, packet: packet1);

let destinationNames = getDestinationNames()
for (index,destName) in destinationNames.enumerated()
{
    print("Destination #\(index): \(destName)")
}

let destNum = 0
print("Using destination #\(destNum)")

var dest:MIDIEndpointRef = MIDIGetDestination(destNum);
print("Playing note for 1 second on channel 1")
MIDISend(outPort, dest, &packetList);
packet1.data.0 = 0x80 + 0; // Note Off event channel 1
packet1.data.2 = 0; // Velocity
sleep(1);
packetList = MIDIPacketList(numPackets: 1, packet: packet1);
MIDISend(outPort, dest, &packetList);
print("Note off sent")


// A packet is just a way of thinking about multiple bytes as a single thing

