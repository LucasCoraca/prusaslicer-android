#!/bin/bash
# Our own test emulator: AVD "pstab" (avd/, 1280x800 tablet at DPR 1, made with avdmanager from the android-34
# google_apis x86_64 image), port 5580 => serial emulator-5580. Other agents' emulators are never touched.
# PS_AVD=psphone: a 720x1520 phone at DPR 2 (360x760 dp; PS_SCALE=2 for tap.sh/shot.sh). Use it rather than
# `wm size` on pstab: scaling an overridden size onto the tablet framebuffer grew qemu by ~3 GB a minute.
# Kept small for the shared machine: a 2560x1600 DPR 2 AVD cost ~12 GB of host RAM with PrusaSlicer running (GPU emulation).
# A watchdog kills the emulator if qemu grows past $PS_EMU_MAX_MB (default 6000).
source "$(dirname "$0")/env.sh"
export ANDROID_AVD_HOME=$R/avd ANDROID_USER_HOME=$R/hosttools/androiduser
MAX=${PS_EMU_MAX_MB:-6000}
nice -n 19 $ANDROID_SDK_ROOT/emulator/emulator -avd ${PS_AVD:-pstab} -port 5580 -no-window -no-audio -no-boot-anim \
  -no-snapshot -gpu ${PS_EMU_GPU:-swangle_indirect} -memory 3072 -cores 2 &
EMU=$!
while kill -0 $EMU 2>/dev/null; do
  sleep 10
  RSS=$(ps -o rss=,args= -C qemu-system-x86_64-headless | grep -- "-port 5580" | awk '{print int($1/1024)}')
  if [ -n "$RSS" ] && [ "$RSS" -gt "$MAX" ]; then
    echo "$(date) watchdog: qemu at ${RSS} MB > ${MAX} MB, stopping the emulator"
    $ANDROID_SDK_ROOT/platform-tools/adb -s emulator-5580 emu kill
  fi
done
