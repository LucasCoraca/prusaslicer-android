#!/bin/bash
# Check out the pinned upstream sources and apply the Android patches:
#   prusaslicer-src/         prusa3d/PrusaSlicer (version_2.9.6)
#   third_party/wxWidgets/   SoftFever/Orca-deps-wxWidgets (wxWidgets 3.3 fork) + the wxQt-on-Android patch shared with
#                            the OrcaSlicer port (github.com/LucasCoraca/orcaslicer-android)
set -e
cd "$(dirname "$0")"
PS_COMMIT=b028299c770b8380ee81c921a2867d522f288123
WX_COMMIT=88f3483ca546fbf4ad732e1acd94cc930935077a
checkout() {  # <url> <dir> <commit> <patch>
  if [ ! -d "$2/.git" ]; then
    git init -q "$2"; git -C "$2" remote add origin "$1"
  fi
  git -C "$2" fetch -q --depth 1 origin "$3"
  git -C "$2" checkout -q --force "$3"
  git -C "$2" submodule update -q --init --recursive --depth 1 || true
  git -C "$2" apply --index "$PWD/$4"
  echo "$2: $(git -C "$2" log -1 --format='%h %s') + $(basename "$4")"
}
checkout https://github.com/prusa3d/PrusaSlicer.git prusaslicer-src $PS_COMMIT patches/prusaslicer-android.patch
checkout https://github.com/SoftFever/Orca-deps-wxWidgets.git third_party/wxWidgets $WX_COMMIT patches/wxWidgets-android.patch
