#!/bin/bash
# This script will activate AudioMultiProcessing with arguments.

# Perform Extortion
# ./Executables/AudioMultiProcessing "./Media/DillaOrgan.wav" "./Media/DillaOrganExtorted.caf" 6 0.35

# Perform Rectification
# ./Executables/AudioMultiProcessing "./Media/JF_u10.wav" "./Media/JF_u10Rect.caf" 3

# afconvert -f WAVE -d LEI16 "./Media/JF_u10Rect.caf" "./Media/JF_u10Rect.wav"

# Perform Inversion
# ./Executables/AudioMultiProcessing "./Media/DillaOrganExtorted.caf" "./Media/DillaOrganInv.caf" 4

# Perform Normalization
# ./Executables/AudioMultiProcessing "./Media/DillaOrganInv.caf" "./Media/DillaOrganNorm.caf" 1

Perform Fade In
./Executables/AudioMultiProcessing "./Media/DillaOrgan.wav" "./Media/DillaOrganFadeIn.caf" 7 3
