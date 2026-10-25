#!/bin/bash
# tap.sh x y [wait_s]: tap our emulator at half-size screenshot coordinates (= logical px at DPR 2)
$HOME/Android/sdk/platform-tools/adb -s ${PS_SERIAL:-emulator-5580} shell input tap $(( $1 * 2 )) $(( $2 * 2 ))
sleep ${3:-2}
