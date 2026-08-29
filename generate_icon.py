#!/usr/bin/env python3
"""Erzeugt das AppIcon.png (1024x1024) fuer MuTTY."""
from PIL import Image, ImageDraw, ImageFont
import os

SIZE = 1024
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "AppIcon.png")

img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
d = ImageDraw.Draw(img)

# Hintergrund: abgerundetes Rechteck, dunkles Navy
bg = (18, 24, 38, 255)
d.rounded_rectangle([0, 0, SIZE - 1, SIZE - 1], radius=228, fill=bg)

# Terminalfenster
pad = 150
win = [pad, pad, SIZE - pad, SIZE - pad]
d.rounded_rectangle(win, radius=64, fill=(30, 41, 59, 255), outline=(51, 65, 85, 255), width=4)

# Titelleiste
bar_h = 120
bar_box = [pad, pad, SIZE - pad, pad + bar_h]
d.rounded_rectangle(bar_box, radius=64, fill=(15, 23, 42, 255))
d.rectangle([pad, pad + 40, SIZE - pad, pad + bar_h], fill=(15, 23, 42, 255))

# Drei Punkte (macOS-Fenster-Buttons)
dot_y = pad + 60
dot_r = 22
dot_colors = [(255, 95, 86), (255, 189, 46), (39, 201, 63)]
dot_x = pad + 70
for c in dot_colors:
    d.ellipse([dot_x - dot_r, dot_y - dot_r, dot_x + dot_r, dot_y + dot_r], fill=c)
    dot_x += 70

# Prompt-Text ">_"
prompt = ">_"
font = None
candidates = [
    "/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf",
    "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf",
]
for path in candidates:
    if os.path.exists(path):
        font = ImageFont.truetype(path, 300)
        break
if font is None:
    font = ImageFont.load_default()

bbox = d.textbbox((0, 0), prompt, font=font)
tw = bbox[2] - bbox[0]
th = bbox[3] - bbox[1]
tx = (SIZE - tw) // 2 - bbox[0]
ty = pad + bar_h + (SIZE - pad - (pad + bar_h) - th) // 2 - bbox[1]
d.text((tx, ty), prompt, font=font, fill=(52, 211, 153, 255))

img.save(OUT)
print("Gespeichert:", OUT)
