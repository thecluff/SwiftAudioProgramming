import Cocoa

// Find the frequency for each midi note number from 0 through 127.
// In the mini standard, there are several types of standard midi channel messages defined.
// NoteOn, NoteOff, Controller Changes, Pitch Bend, program changes. These are all midi channel voice messages.
// Midi NoteOn or NoteOff message consists of three bytes:

// Status byte - identifies message type
// Two data bytes - first of which is midi note number. The second of which is the velocity.

// Data bytes have a range of 128 (Seven bits) which is zero based, so they go from 0 through 127.
// The numbering starts on C, and every 12th note is the C in some octave.
// 0, 12, 24, 36, 48, 60, etc
// Objective for this exercise is to find the frequency for each note in the scale.
// The default tuning assumes 12-note equal temperament, which is to say the frequency ratio between any two half steps is always the same.
// * An octave is doubling of frequency.
// * While transposition by note name or note number is additive, transposition by frequency is by multiplication.
// * The same multiplier is used for all half steps. What is that multiplier?
// * what number multiplied by itself twelve times is 2?
// * That number must be the 12th root of two

let magicInterval = pow(Double(2), Double(1.0/12))

let octave = pow(1.059463094359295, Double(12))
// What is C above A440?
// A440 is tuning reference
let A440 = 440.0
let CAboveA440 = A440 * pow(magicInterval, Double(3))
let C0 = CAboveA440 * pow(Double(2), Double(-6))

var buffer = [Double]()
// Set the first element of the array to C0
buffer.append(C0)
// Use a loop which is controlled iteration, generate the other frequency values
for index in 1...127 {
    buffer.append(buffer[index-1]*magicInterval)
}
// We can use a dictionary to provide the note names

var noteNames: [Int: String] = [0: "C",
                                1: "C#/Db",
                                2: "D",
                                3: "D#/Eb",
                                4: "E",
                                5: "F",
                                6: "F#/Gb",
                                7: "G",
                                8: "G#/Ab",
                                9: "A",
                                10: "A#/Bb",
                                11: "B"]

for index in 0...127 {
    print(String(format:"%d\t\t%.7f", index, buffer[index]) + String(format:"\t\t") + String(noteNames[index%12]!))
}

// When using a dictionary, we provide a key to the dictionary, and it returns a value.
// Swift interprets dictionary lookups as risky. For example, there is no value to noteNames[12]
// For that reason, it demands that we use the '!' after the variable name + index to assert that there might not be a valid value.
// If we say noteNames[0]! then the dictionary will return the value C.
// All of that is good only up through noteNames[11]. After that, there are no more values in the dictionary.
// Because the pattern repeats cyclically. We use the modulo division operator '('%' to say divide the index by 12, and leave the remainder.

