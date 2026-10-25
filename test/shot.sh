#!/bin/bash
# shot.sh name: screenshot (divided by PS_SCALE) of our emulator to build/screens/<name>.png
D="$(cd "$(dirname "$0")/.." && pwd)/build/screens"; mkdir -p $D
$HOME/Android/sdk/platform-tools/adb -s ${PS_SERIAL:-emulator-5580} exec-out screencap -p > $D/full.png
python3 -c "from PIL import Image; im=Image.open('$D/full.png'); im.convert('RGB').resize((im.width//${PS_SCALE:-1}, im.height//${PS_SCALE:-1})).save('$D/$1.png')"
echo $D/$1.png
