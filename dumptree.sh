#!/bin/bash
# Dump the running app's wx window tree (android/app/debugtools.cpp). usage: dumptree.sh [egrep filter]
source "$(dirname "$0")/env.sh"
A="$ANDROID_SDK_ROOT/platform-tools/adb -s ${PS_SERIAL:-emulator-5580}"
$A logcat -c
$A shell "run-as org.prusaport.slicer touch files/dump_tree"
for i in $(seq 1 20); do sleep 1; $A logcat -d -s prusa-tree:I | grep -q END && break; done
$A logcat -d -s prusa-tree:I | sed 's/^.*prusa-tree: //' | grep -E "${1:-.}"
