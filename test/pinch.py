#!/usr/bin/env python3
"""pinch.py <out_dir> <cx> <cy> <r0> <r1> [steps] [angle_deg]
Two-finger pinch around (cx, cy) (physical screen px of the 2560x1600 emulator) from finger distance r0 to r1, as raw
Linux input_event frames (multi-touch protocol B) for /dev/input/event2. Writes <out_dir>/f000.bin ...; replay with
test/pinch.sh. r1 > r0 zooms in."""
import math, os, struct, sys
out, cx, cy, r0, r1 = sys.argv[1], *map(float, sys.argv[2:6])
steps = int(sys.argv[6]) if len(sys.argv) > 6 else 15
ang = math.radians(float(sys.argv[7]) if len(sys.argv) > 7 else 30)
EV_SYN, EV_KEY, EV_ABS = 0, 1, 3
SLOT, TID, X, Y, PRESS, TOUCH = 0x2f, 0x39, 0x35, 0x36, 0x3a, 0x14a
W, H, M = 2560, 1600, 32767
ev = lambda t, c, v: struct.pack("<qqHHi", 0, 0, t, c, v)
def fingers(r):
    dx, dy = math.cos(ang) * r / 2, math.sin(ang) * r / 2
    return [(cx - dx, cy - dy), (cx + dx, cy + dy)]
os.makedirs(out, exist_ok=True)
frames = []
for i in range(steps + 1):
    r = r0 + (r1 - r0) * i / steps
    b = b""
    for slot, (x, y) in enumerate(fingers(r)):
        b += ev(EV_ABS, SLOT, slot)
        if i == 0:
            b += ev(EV_ABS, TID, 100 + slot)
        b += ev(EV_ABS, X, int(x * M / W)) + ev(EV_ABS, Y, int(y * M / H)) + ev(EV_ABS, PRESS, 50)
    if i == 0:
        b += ev(EV_KEY, TOUCH, 1)
    frames.append(b + ev(EV_SYN, 0, 0))
frames.append(ev(EV_ABS, SLOT, 0) + ev(EV_ABS, TID, -1) + ev(EV_ABS, SLOT, 1) + ev(EV_ABS, TID, -1)
              + ev(EV_KEY, TOUCH, 0) + ev(EV_SYN, 0, 0))
for i, f in enumerate(frames):
    open(os.path.join(out, "f%03d.bin" % i), "wb").write(f)
print(len(frames), "frames")
