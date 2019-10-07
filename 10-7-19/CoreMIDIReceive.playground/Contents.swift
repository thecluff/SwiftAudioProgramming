import Cocoa
import CoreMIDI
import PlaygroundSupport

func getDisplayName(_ obj: MIDIObjectRef) -> String {
    var param: Unmanaged<CFString>?
    var name: String = "Error"
    
    let err: OSStatus = MIDIObjectGetStringProperty(obj, kMIDIPropertyDisplayName, &param)
    if err == OSStatus(noErr) {
        name = param!.takeRetainedValue() as String
    }
    return name
}

// Callback function - function that is called by the system, not the application
func myMIDIReadProc(pktList: UnsafePointer<MIDIPacketList>, readProcRefCon: UnsafeMutableRawPointer?, srcConnRefCon: UnsafeMutableRawPointer?) -> Void {
    let packetList: MIDIPacketList = pktList.pointee
    let srcRef: MIDIEndpointRef = srcConnRefCon!.load(as: MIDIEndpointRef.self)
    
    print("MIDI Received from Sourc: \(getDisplayName(srcRef))" )
    
    var packet:MIDIPacket = packetList.packet
    
    for _ in 1...packetList.numPackets {
        let bytes = Mirror(reflecting: packet.data).children
        var dumpStr = ""
        
        // Loop to iterate through the packet length
        var i = packet.length
        for(_, attr) in bytes.enumerated() {
            dumpStr += String(format:"$%02X ", attr.value as! UInt8)
            i -= 1;
            if (i <= 0) {
                break;
            }
        }
        // Print the contents of the message
        print(dumpStr)
        packet = MIDIPacketNext(&packet).pointee
    }
}


var midiClient: MIDIClientRef = 0
var inPort: MIDIPortRef = 0
var src: MIDIEndpointRef = MIDIGetSource(0)

MIDIClientCreate("MIDITestClient" as CFString, nil, nil, &midiClient)
MIDIInputPortCreate(midiClient, "MIDITest_InPort" as CFString, myMIDIReadProc, nil, &inPort)

MIDIPortConnectSource(inPort, src, &src)

// Keep playground running
PlaygroundPage.current.needsIndefiniteExecution = true

