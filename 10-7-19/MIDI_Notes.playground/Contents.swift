0x90 to 0x9F

//: ## System of control messages

//: ### Channel voice messages - 10 bit messages

//: #### (Two bits are stripped off when going from hardware to software)

//: 8 bit messages, of which 7 bits are the norm for the message values

//: * Status byte identifies the type of message *

//: * Data bytes are 7 bits, which is to say 0 through 127.

//: Binary is often expressed as hexadecimal


//: 1111 15 F

//: 1110 14 E

//: 1101 13 D

//: 1100 12 C

//: 1011 11 B

//: 1010 10 A

//: 1001 9  9

//: 1000 8  8

//: 0111 7  7

//: 0110 6  6

//: 0101 5  5

//: 0100 4  4

//: 0011 3  3

//: 0010 2  2

//: 0001 1  1

//: 0000 0  0


//: 0000|1000 = x08

//: 1000|0000 = x80

//: *Status & Data bytes*


//: ## noteOff - status byte, 2 data bytes

//:     noteOff status goes from 0x80 to 0x8F, or 128 to 143

//:     data1 = MIDI Note number, data2 = velocity


//: ## noteOn - status byte, 2 data bytes

//:     noteOn status goes from 0x90 to 0x9F, or 144 to 159

//:     velocity of zero = noteoff


//: ## Aftertouch (polyphonic) - status byte, 2 data bytes

//:     Aftertouch status goes from 0xA0 to 0xAF, or 160 to 175

//:     data1 = MIDI note number, data2 = value


//: ## Continuous controller messages - status byte, 2 data bytes

//:     Continuous controller goes from 0xB0 to 0xBF, or 176 to 191

//:     data1 = controller number(i.e., 0 = mod wheel, 7 = volume), data2 = value


//: ## Instrument number (program change) - status byte, 1 data byte

//:     Instrument number status goes from 0xC0 to 0xCF, or 192 to 207

//:     data1=program number


//: ## Note pressure (channel pressure) - status byte, 2 data bytes

//:     Note pressure status goes from 0xD0 to 0xDF, or 208 to 223

//:     data1=pressure value


//: ## Pitch bend - status byte, 2 data bytes

//:     Pitch bend status goes from 0xE0 to 0xEF 224 to 239

//:     data1 + data2 = 14 bits (16384, or -8192 to 8191


//: 0xF0 - System messages


//: *Standard MIDI file (SMF)*

//: Type 0 = monophonic MIDI file

//: Type 1 = polyphonic

//: Type 2 = polyphonic, but no set way of interpreting how the voices relate to each other.

//: MIDI messages are vectored. They have a time interval that is specified between each message




//: 1

//: 2

//: 4

//: 8

//: 16

//: 32

//: 64

//: 128

//: 256

//: ----

//: 512

//: 1024

//: 2048

//: 4096

//: 8192

//: 16384

//: 32768

//: 65536


//: 128

//: 64

//: 32

//: 16

//: ----

//: 8

//: 4

//: 2

//: 1
