#!/bin/bash
# Configure PrusaSlicer + the packaged Android app (GUI on, Qt toolchain). usage: configure-app.sh [x86_64|arm64-v8a] [extra cmake args]
ABI=${1:-x86_64}
source "$(dirname "$0")/env.sh"
QT=$(qt_for $ABI)
P=$R/deps-android/$ABI/usr/local
# Boost/Eigen are pinned: the Qt prefix (fcdeps) carries other versions that must not be picked up.
cmake -S $R/prusaslicer-src -B $R/build/app-$ABI -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_TOOLCHAIN_FILE=$QT/lib/cmake/Qt6/qt.toolchain.cmake -DQT_HOST_PATH=$QT_HOST_PATH \
  -DANDROID_ABI=$ABI -DANDROID_PLATFORM=android-28 \
  -DCMAKE_PREFIX_PATH="$P;$QT" -DCMAKE_FIND_ROOT_PATH="$P;$QT" \
  -DwxWidgets_DIR=$P/lib/cmake/wxWidgets-3.3 -DBoost_DIR=$P/lib/cmake/Boost-1.83.0 -DEigen3_DIR=$P/share/eigen3/cmake \
  -DPS_DEPS_PREFIX=$P -DSLIC3R_GUI=ON -DSLIC3R_STATIC=ON -DSLIC3R_PCH=ON -DSLIC3R_BUILD_TESTS=OFF \
  -DPS_ANDROID_APP=ON -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  "${@:2}"
