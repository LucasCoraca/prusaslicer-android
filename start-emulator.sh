#!/bin/bash
# Our own test emulator: AVD "orcatest" (shared with the OrcaSlicer port, in its hosttools/avd), port 5580 => serial
# emulator-5580. Other agents' emulators are never touched. Kept small: the machine is shared.
# GPU: "guest" renders with SwiftShader inside the guest, so GPU memory comes out of the fixed guest RAM. With host-side
# rendering (swangle_indirect) qemu grew to 12 GB within minutes of starting PrusaSlicer.
# A watchdog kills the emulator if qemu still grows past $PS_EMU_MAX_MB (default 6000).
source "$(dirname "$0")/env.sh"
export ANDROID_AVD_HOME=$R/hosttools/avd ANDROID_USER_HOME=$R/hosttools/androiduser
MAX=${PS_EMU_MAX_MB:-6000}
nice -n 19 $ANDROID_SDK_ROOT/emulator/emulator -avd orcatest -port 5580 -no-window -no-audio -no-boot-anim \
  -no-snapshot -gpu ${PS_EMU_GPU:-guest} -memory 3072 -cores 2 &
EMU=$!
while kill -0 $EMU 2>/dev/null; do
  sleep 10
  RSS=$(ps -o rss=,args= -C qemu-system-x86_64-headless | grep -- "-port 5580" | awk '{print int($1/1024)}')
  if [ -n "$RSS" ] && [ "$RSS" -gt "$MAX" ]; then
    echo "$(date) watchdog: qemu at ${RSS} MB > ${MAX} MB, stopping the emulator"
    $ANDROID_SDK_ROOT/platform-tools/adb -s emulator-5580 emu kill
  fi
done
