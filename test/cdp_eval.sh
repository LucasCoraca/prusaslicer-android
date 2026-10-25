#!/bin/bash
# cdp_eval.sh '<js>': run JS in the app's web view (see cdp_eval.py)
A="$HOME/Android/sdk/platform-tools/adb -s ${PS_SERIAL:-emulator-5580}"
P=$($A shell pidof org.prusaport.slicer | tr -d '\r')
$A forward tcp:9333 localabstract:webview_devtools_remote_$P >/dev/null
timeout 20 python3 "$(dirname "$0")/cdp_eval.py" "$1"
