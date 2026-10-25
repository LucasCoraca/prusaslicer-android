#!/bin/bash
# Full arm64-v8a build: deps superbuild, wxWidgets, app + APK, signed into dist/. Frees the deps build tree after
# installing (the disk is shared and tight). Log per step in build/arm64-*.log.
source "$(dirname "$0")/env.sh"
ABI=arm64-v8a
set -o pipefail
step() { echo "$(date +%H:%M) $1"; }
step deps-configure; ./configure-deps.sh $ABI > build/arm64-deps-configure.log 2>&1 || exit 1
step deps; ./run-deps.sh $ABI > build/arm64-deps.log 2>&1 || { grep "FAILED: \[code=1\] dep_" build/arm64-deps.log; exit 1; }
rm -rf build/deps-arm64
step wx; ./configure-wx.sh $ABI > build/arm64-wx-configure.log 2>&1 && (cd build/wx-$ABI && nice -n 19 ninja -j$JOBS && ninja install) > build/arm64-wx.log 2>&1 || exit 1
step app-configure; ./configure-app.sh $ABI > build/arm64-app-configure.log 2>&1 || exit 1
step app; ./build-app.sh $ABI prusaslicer_make_apk > build/arm64-app.log 2>&1 || { grep -m10 "error:\|FAILED" build/arm64-app.log; exit 1; }
$BT/apksigner sign --ks $PS_KEYSTORE --ks-pass pass:android --key-pass pass:android \
  --out dist/PrusaSlicer-android-arm64-preview.apk build/app-$ABI/android-app/android-build/prusaslicer.apk || exit 1
step done; ls -la dist/
