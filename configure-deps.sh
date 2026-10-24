#!/bin/bash
# Configure PrusaSlicer's dependency superbuild for Android. usage: configure-deps.sh [arm64-v8a|x86_64]
# Trees: build/deps-<arm64|x86_64>, prefix deps-android/<abi>/usr/local, downloads in dl-cache/.
ABI=${1:-arm64-v8a}
source "$(dirname "$0")/env.sh"
cmake -S $R/prusaslicer-src/deps -B $R/build/deps-$(short $ABI) -G Ninja -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_TOOLCHAIN_FILE=$NDK/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=$ABI -DANDROID_PLATFORM=android-28 -DANDROID_STL=c++_shared \
  -DDEP_MAX_THREADS=$JOBS \
  -DDESTDIR=$R/deps-android/$ABI -DDEP_DOWNLOAD_DIR=$R/dl-cache
