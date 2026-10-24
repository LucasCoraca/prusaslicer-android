#!/usr/bin/env python3
"""Render the Android launcher icons from PrusaSlicer's logo (resources/icons/PrusaSlicer.svg: two half discs).

usage: make_launcher_icon.py <res_dir>
Writes mipmap-*/ic_launcher{,_round,_foreground}.png; the adaptive icon XML lives next to them in the repo.
"""
import math, os, sys
from PIL import Image, ImageDraw

DARK, ORANGE = (0x36, 0x36, 0x36, 255), (0xED, 0x6B, 0x21, 255)
R = math.hypot(340, 340) / 2  # both half discs, in the SVG's 800x800 space


def half_disc(c, a0):
    """polygon of the half disc centred at c, spanning angles a0 .. a0+180 degrees"""
    return [(c[0] + R * math.cos(math.radians(a0 + t)), c[1] + R * math.sin(math.radians(a0 + t))) for t in range(0, 181)]


def logo(size, scale, background=None, round_bg=False):
    ss = 4  # supersampling
    S = size * ss
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    if background:
        if round_bg:
            d.ellipse([0, 0, S - 1, S - 1], fill=background)
        else:
            d.rounded_rectangle([0, 0, S - 1, S - 1], radius=S * 0.18, fill=background)
    k = S * scale / 800.0
    off = (S - 800 * k) / 2
    tr = lambda pts: [(off + x * k, off + y * k) for x, y in pts]
    # upper-left half: chord from (599.3,186.8) to (259.3,526.8), the arc bulging up-left
    d.polygon(tr(half_disc((429.3, 356.8), 135)), fill=DARK)
    # lower-right half: chord from (202.7,612.5) to (542.7,272.5)
    d.polygon(tr(half_disc((372.7, 442.5), -45)), fill=ORANGE)
    return img.resize((size, size), Image.LANCZOS)


res = sys.argv[1]
for name, dens in (("mdpi", 1), ("hdpi", 1.5), ("xhdpi", 2), ("xxhdpi", 3), ("xxxhdpi", 4)):
    d = os.path.join(res, "mipmap-" + name)
    os.makedirs(d, exist_ok=True)
    legacy = int(48 * dens)
    logo(legacy, 0.80, (255, 255, 255, 255)).save(os.path.join(d, "ic_launcher.png"))
    logo(legacy, 0.80, (255, 255, 255, 255), round_bg=True).save(os.path.join(d, "ic_launcher_round.png"))
    # adaptive foreground: 108dp canvas, the logo inside the 66dp safe zone
    logo(int(108 * dens), 0.62).save(os.path.join(d, "ic_launcher_foreground.png"))
print("icons written to", res)
