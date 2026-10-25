#!/bin/bash
# Fresh config, then through the Configuration Wizard to its Filaments page with the CORE One INDX 4T picked.
# Tablet emulator (2560x1600) coordinates; waits are generous because the shared host is often loaded.
cd "$(dirname "$0")/.."
A="$HOME/Android/sdk/platform-tools/adb -s ${PS_SERIAL:-emulator-5580}"
$A shell "run-as org.prusaport.slicer rm -f files/PrusaSlicer/PrusaSlicer.ini"
./run-app.sh 45 ${1:-} | head -3
test/tap.sh 980 735 8    # Welcome -> Log in
test/tap.sh 980 735 6    # -> Configuration sources
test/tap.sh 980 735 50   # -> profile download -> Prusa Research printers
test/tap.sh 585 522 5    # CORE One INDX 4T, HF0.4 nozzle
test/tap.sh 137 404 10   # index: Filaments
test/shot.sh filaments
