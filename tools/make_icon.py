# Draws the Chitra AI logo and exports the Android launcher icons.
# The same numbers are used by lib/repair/widgets/chitra_logo.dart.
import math, os
from PIL import Image, ImageDraw

NAVY = (0x0F, 0x12, 0x21)
BLUE = (0x8C, 0x98, 0xFE)
VIOLET = (0xAB, 0x9B, 0xFE)
GOLD = (0xFF, 0xC2, 0x4D)
SMALL = (0x9A, 0x9A, 0xFE)

CENTER = (0.405, 0.503)
RADIUS = 0.29
MAX_W = 0.15
START = math.radians(42)    # round end of the crescent
SWEEP = math.radians(284)   # goes clockwise to the thin tip


def width_at(u):
    # full width for the round end, then it narrows smoothly to the thin tip
    if u < 0.1:
        return MAX_W
    t = (u - 0.1) / 0.9
    return MAX_W * max(0.0, math.cos(math.pi / 2 * t)) ** 0.8


def crescent_points(n=240):
    outer, inner = [], []
    for i in range(n + 1):
        u = i / n
        a = START + SWEEP * u
        w = width_at(u)
        cx, cy = math.cos(a), math.sin(a)
        outer.append((CENTER[0] + (RADIUS + w / 2) * cx, CENTER[1] + (RADIUS + w / 2) * cy))
        inner.append((CENTER[0] + (RADIUS - w / 2) * cx, CENTER[1] + (RADIUS - w / 2) * cy))
    return outer + inner[::-1]


def star_points(cx, cy, r, n=96, p=0.75):
    e = 2 / p
    pts = []
    for i in range(n):
        t = 2 * math.pi * i / n
        c, s = math.cos(t), math.sin(t)
        pts.append((cx + r * math.copysign(abs(c) ** e, c), cy + r * math.copysign(abs(s) ** e, s)))
    return pts


def render_logo(px, mono=False):
    """Logo on a transparent square of px pixels (logo space 0..1)."""
    big = px * 3
    def P(pts): return [(x * big, y * big) for x, y in pts]
    mask = Image.new('L', (big, big), 0)
    d = ImageDraw.Draw(mask)
    d.polygon(P(crescent_points()), fill=255)
    ex = CENTER[0] + RADIUS * math.cos(START)
    ey = CENTER[1] + RADIUS * math.sin(START)
    r = width_at(0) / 2
    d.ellipse([(ex - r) * big, (ey - r) * big, (ex + r) * big, (ey + r) * big], fill=255)
    if mono:
        layer = Image.new('RGBA', (big, big), (255, 255, 255, 255))
    else:
        grad = Image.new('RGB', (big, big))
        gp = grad.load()
        for y in range(big):
            for x in range(big):
                t = (x + y) / (2 * big)
                gp[x, y] = tuple(int(BLUE[k] + (VIOLET[k] - BLUE[k]) * t) for k in range(3))
        layer = grad.convert('RGBA')
    layer.putalpha(mask)
    out = Image.new('RGBA', (big, big), (0, 0, 0, 0))
    out.alpha_composite(layer)
    s = ImageDraw.Draw(out)
    s.polygon(P(star_points(0.800, 0.242, 0.110)), fill=(255, 255, 255, 255) if mono else GOLD + (255,))
    s.polygon(P(star_points(0.918, 0.371, 0.037)), fill=(255, 255, 255, 255) if mono else SMALL + (255,))
    return out.resize((px, px), Image.LANCZOS)


def on_canvas(px, logo_fraction, bg=None, mono=False):
    canvas = Image.new('RGBA', (px, px), bg + (255,) if bg else (0, 0, 0, 0))
    size = int(px * logo_fraction)
    logo = render_logo(size, mono)
    # the logo content is centred around (0.57, 0.52) of its box, so shift to centre it
    off_x = int((px - size) / 2 + size * (0.5 - 0.585))
    off_y = int((px - size) / 2 + size * (0.5 - 0.50))
    canvas.alpha_composite(logo, (off_x, off_y))
    return canvas


if __name__ == '__main__':
    res = 'android/app/src/main/res'
    dens = {'mdpi': 1, 'hdpi': 1.5, 'xhdpi': 2, 'xxhdpi': 3, 'xxxhdpi': 4}
    for name, f in dens.items():
        d = f'{res}/mipmap-{name}'
        os.makedirs(d, exist_ok=True)
        # legacy square icon (Android 7 and older)
        on_canvas(int(48 * f), 0.78, NAVY).convert('RGB').save(f'{d}/ic_launcher.png')
        # adaptive icon layers, 108dp, logo kept inside the 66 percent safe zone
        on_canvas(int(108 * f), 0.62).save(f'{d}/ic_launcher_foreground.png')
        on_canvas(int(108 * f), 0.62, mono=True).save(f'{d}/ic_launcher_monochrome.png')
    os.makedirs(f'{res}/mipmap-anydpi-v26', exist_ok=True)
    open(f'{res}/mipmap-anydpi-v26/ic_launcher.xml', 'w').write(
'''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
    <monochrome android:drawable="@mipmap/ic_launcher_monochrome"/>
</adaptive-icon>
''')
    os.makedirs(f'{res}/values', exist_ok=True)
    open(f'{res}/values/ic_launcher_background.xml', 'w').write(
'''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#0F1221</color>
</resources>
''')
    on_canvas(1024, 0.80, NAVY).convert('RGB').save('branding/chitra_icon_1024.png')
    on_canvas(512, 0.80, NAVY).convert('RGB').save('branding/chitra_icon_512_playstore.png')
    print('ok')
