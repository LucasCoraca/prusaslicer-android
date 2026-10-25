#!/bin/bash
# Build the dependency superbuild configured by configure-deps.sh. usage: run-deps.sh <arm64-v8a|x86_64> [targets]
source "$(dirname "$0")/env.sh"
ABI=${1:-arm64-v8a}; shift
cd $R/build/deps-$(short $ABI) && exec nice -n 19 ninja -j2 -k 0 ${@:-deps}
