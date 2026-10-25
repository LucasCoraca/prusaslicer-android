#!/bin/bash
# Our own test emulator: AVD "orcatest" (shared with the OrcaSlicer port, in its hosttools/avd), port 5580 => serial
# emulator-5580. Other agents' emulators are never touched. Kept small: the machine is shared (2 cores, 3 GB).
source "$(dirname "$0")/env.sh"
export ANDROID_AVD_HOME=$R/hosttools/avd ANDROID_USER_HOME=$R/hosttools/androiduser
exec nice -n 19 $ANDROID_SDK_ROOT/emulator/emulator -avd orcatest -port 5580 -no-window -no-audio -no-boot-anim \
  -no-snapshot -gpu swangle_indirect -memory 3072 -cores 2
