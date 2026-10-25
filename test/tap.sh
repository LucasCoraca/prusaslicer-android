#!/bin/bash
# tap.sh x y [wait_s]: tap our emulator at screenshot (= logical) px; PS_SCALE=2 for a DPR 2 emulator with half-size shots
$HOME/Android/sdk/platform-tools/adb -s ${PS_SERIAL:-emulator-5580} shell input tap $(( $1 * ${PS_SCALE:-1} )) $(( $2 * ${PS_SCALE:-1} ))
sleep ${3:-2}
