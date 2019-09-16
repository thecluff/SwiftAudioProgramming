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
let C0 = CAboveA440 * pow(CAboveA440, Double(-6))

