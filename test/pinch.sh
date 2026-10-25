#!/bin/bash
# pinch.sh <cx> <cy> <r0> <r1> [steps] [angle]: two-finger pinch on our emulator (needs `adb root`), physical px
D="$(cd "$(dirname "$0")/.." && pwd)/build/pinch"; rm -rf $D
python3 "$(dirname "$0")/pinch.py" $D "$@" >/dev/null
A="$HOME/Android/sdk/platform-tools/adb -s ${PS_SERIAL:-emulator-5580}"
$A shell "rm -rf /data/local/tmp/ps-pinch; mkdir -p /data/local/tmp/ps-pinch" && $A push -q $D/. /data/local/tmp/ps-pinch/
$A shell 'for f in /data/local/tmp/ps-pinch/f*.bin; do cat $f > /dev/input/event2; sleep 0.04; done'
