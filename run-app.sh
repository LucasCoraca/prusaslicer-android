#!/bin/bash
# Install dist/ APK on our emulator, launch, wait, screenshot to $S/ps-latest.png (half size: ps-latest-s.png), print crash backtrace.
# usage: run-app.sh [wait_seconds] [--no-install]     serial: $PS_SERIAL (default emulator-5580, our own AVD)
source "$(dirname "$0")/env.sh"
A="$ANDROID_SDK_ROOT/platform-tools/adb -s ${PS_SERIAL:-emulator-5580}"
S=${S:-$R/build/screens}; mkdir -p $S
WAIT=${1:-30}
$A shell am force-stop org.prusaport.slicer
[ "$2" = "--no-install" ] || $A install -r $R/dist/PrusaSlicer-android-x86_64-preview.apk | tail -1
$A logcat -c
$A shell monkey -p org.prusaport.slicer -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
sleep $WAIT
echo "pid: $($A shell pidof org.prusaport.slicer)"
$A exec-out screencap -p > $S/ps-latest.png
python3 -c "from PIL import Image; im=Image.open('$S/ps-latest.png'); im.convert('RGB').resize((im.width//${PS_SCALE:-1}, im.height//${PS_SCALE:-1})).save('$S/ps-latest-s.png')"
# the emulator's qemu grows with host-side GPU memory (swangle); restart it before it eats the shared host
RSS=$(ps -o rss=,args= -C qemu-system-x86_64-headless | grep -- "-port 5580" | awk '{print int($1/1024)}')
[ -n "$RSS" ] && [ "$RSS" -gt 6000 ] && echo "WARNING: emulator qemu at ${RSS} MB - restart it (adb -s emulator-5580 emu kill; ./start-emulator.sh)"
$A logcat -d | grep -E "F DEBUG +: +(#[0-9]+|signal|Abort)" | sed 's/.*F DEBUG   :  *//; s|/data/app/[^ ]*/lib/x86_64/||; s/(BuildId: [0-9a-f]*)//' | head -30
