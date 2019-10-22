//
// Swift MIDI Playground : Matt Grippaldi 1/1/2016
//
import Cocoa
import CoreMIDI

func getDisplayName(obj: MIDIObjectRef) -&gt; String
{
    var param: Unmanaged?
    var name: String = "Error";
    
    let err: OSStatus = MIDIObjectGetStringProperty(obj, kMIDIPropertyDisplayName, &amp;param)
    if err == OSStatus(noErr)
    {
        name =  param!.takeRetainedValue() as String
    }
    
    return name;
}

func getDestinationNames() -&gt; [String]
{
    var names:[String] = [String]();
    
    let count: Int = MIDIGetNumberOfDestinations();
    for (var i=0; i &lt; count; ++i) { let endpoint:MIDIEndpointRef = MIDIGetDestination(i); if (endpoint != 0) { names.append(getDisplayName(endpoint)); } } return names; } func getSourceNames() -&gt; [String]
{
    var names:[String] = [String]();
    
    let count: Int = MIDIGetNumberOfSources();
    for (var i=0; i &lt; count; ++i)
    {
        let endpoint:MIDIEndpointRef = MIDIGetSource(i);
        if (endpoint != 0)
        {
            names.append(getDisplayName(endpoint));
        }
    }
    return names;
}

let destNames = getDestinationNames();
for destName in destNames
{
    print("Destination: \(destName)");
}

let sourceNames = getSourceNames();
for sourceName in sourceNames
{
    print("Source: \(sourceName)");
}
