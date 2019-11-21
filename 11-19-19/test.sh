#!/bin/bash
# This script will activate AudioMultiProcessing with arguments.
# For assets, I synthesized five ~30sec audio samples using Alchemy (Logic Pro X stock instrument patches) in the key of D minor.

# Create a temporary directory for keeping files as they're processed.
mkdir ./audio/temp/

# Begin processing the files

# Apply a low pass filter to Arp1.wav
./Executables/AudioMultiProcessing ./audio/Arp1.wav ./audio/temp/Arp1_LP.caf 14 3
# Apply a high pass filter to Arp2.wav
./Executables/AudioMultiProcessing ./audio/Arp2.wav ./audio/temp/Arp2_HP.caf 14 4


# Apply a low pass filter to Pad1.wav
./Executables/AudioMultiProcessing ./audio/Pad1.wav ./audio/temp/Pad1_LP.caf 14 3
# Apply a high pass filter to Pad2.wav
./Executables/AudioMultiProcessing ./audio/Pad2.wav ./audio/temp/Pad2_HP.caf 14 4

# Convert all files needed next
afconvert -f WAVE -d LEI16 ./audio/temp/Pad1_LP.caf ./audio/temp/Pad1_LP.wav
afconvert -f WAVE -d LEI16 ./audio/temp/Pad2_HP.caf ./audio/temp/Pad2_HP.wav
afconvert -f WAVE -d LEI16 ./audio/temp/Arp1_LP.caf ./audio/temp/Arp1_LP.wav
afconvert -f WAVE -d LEI16 ./audio/temp/Arp2_HP.caf ./audio/temp/Arp2_HP.wav

# Combine The first two "sub busses" of the mix
./Executables/MixProject ./audio/temp/Arp1_LP.wav ./audio/temp/Arp1_LP.wav ./audio/temp/Arp_mixed.wav 0.0 0.5
./Executables/MixProject ./audio/temp/Pad1_LP.wav ./audio/temp/Pad1_LP.wav ./audio/temp/Pad_mixed.wav 0.0 0.5

./Executables/MixProject ./audio/temp/Pad_mixed.wav ./audio/temp/Arp_mixed.wav ./audio/temp/Instruments.wav 0.0 0.5

./Executables/MixProject ./audio/temp/Instruments.wav ./audio/Drops.wav ./FinalMix.wav 0.0 1.0

rm -r ./audio/temp/
