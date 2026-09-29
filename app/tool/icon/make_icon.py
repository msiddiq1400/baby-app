"""Draws the Palna app icon with Pillow.

A crescent-moon cradle on rockers (a palna) holding a sleeping baby, with
stars, on a night-sky gradient. Same palette as the app (lib/app/theme.dart).

Usage (from the app folder):
    python tool/icon/make_icon.py assets/icon

Writes 1024x1024 PNGs:
  icon.png             full icon (stores, iOS, older Android)
  icon_foreground.png  Android adaptive icon foreground (inside the safe zone)
  icon_background.png  Android adaptive icon background (the gradient)
  icon_monochrome.png  Android 13+ themed (monochrome) icon
Drawn at 4x and scaled down for smooth edges.
"""
import math
import os
import sys

from PIL import Image, ImageChops, ImageDraw, ImageFilter

S = 4096
OUT = S // 4

NAVY_TOP = (59, 81, 120)
NAVY_BOTTOM = (31, 45, 74)
CREAM = (250, 238, 214)
SAND = (227, 183, 120)
ROSE = (212, 140, 140)
BLUSH = (246, 210, 190)


def gradient():
    img = Image.new("RGB", (S, S))
    d = ImageDraw.Draw(img)
    for y in range(S):
        t = y / (S - 1)
        d.line([(0, y), (S, y)], fill=tuple(round(NAVY_TOP[i] + (NAVY_BOTTOM[i] - NAVY_TOP[i]) * t) for i in range(3)))
    return img.convert("RGBA")


def circle(cx, cy, r):
    m = Image.new("L", (S, S), 0)
    ImageDraw.Draw(m).ellipse([cx - r, cy - r, cx + r, cy + r], fill=255)
    return m


def rounded_rect(box, r):
    m = Image.new("L", (S, S), 0)
    ImageDraw.Draw(m).rounded_rectangle(box, radius=r, fill=255)
    return m


def star_mask(cx, cy, r):
    pts = []
    for i in range(10):
        a = -math.pi / 2 + i * math.pi / 5
        rr = r if i % 2 == 0 else r * 0.45
        pts.append((cx + rr * math.cos(a), cy + rr * math.sin(a)))
    m = Image.new("L", (S, S), 0)
    ImageDraw.Draw(m).polygon(pts, fill=255)
    return m


def paint(layer, mask, color):
    solid = Image.new("RGBA", (S, S), color + (255,))
    layer.alpha_composite(Image.composite(solid, Image.new("RGBA", (S, S)), mask))


def artwork():
    """Transparent layer with the cradle, baby and stars, centred."""
    fg = Image.new("RGBA", (S, S))
    c = S // 2
    cy = c + 80  # optical centre: the stars sit above

    # Rockers: a thin wide crescent under the cradle.
    rocker = ImageChops.subtract(circle(c, cy - 900, 2050), circle(c, cy - 1060, 2050))
    rocker = ImageChops.multiply(rocker, rounded_rect([c - 1150, cy + 600, c + 1150, cy + 1300], 200))
    paint(fg, rocker, SAND)

    # Cradle: crescent moon opening upwards (a bowl).
    bowl = ImageChops.subtract(circle(c, cy, 1100), circle(c, cy - 380, 1100))
    paint(fg, bowl, CREAM)
    inside = circle(c, cy, 1000)

    # Sleeping baby: head on the left, body under a rose blanket, in the bowl.
    paint(fg, ImageChops.multiply(circle(c - 430, cy + 290, 320), inside), BLUSH)
    blanket = ImageChops.multiply(rounded_rect([c - 190, cy + 110, c + 700, cy + 600], 245), inside)
    paint(fg, blanket, ROSE)

    # Lullaby stars.
    paint(fg, star_mask(c + 620, cy - 1080, 240), SAND)
    paint(fg, star_mask(c - 700, cy - 880, 150), CREAM)
    paint(fg, star_mask(c + 60, cy - 1280, 100), CREAM)
    return fg


def with_shadow(fg):
    alpha = fg.split()[3].filter(ImageFilter.GaussianBlur(70))
    sh = Image.new("RGBA", (S, S), (10, 18, 35, 0))
    sh.putalpha(alpha.point(lambda v: v * 90 // 255))
    out = Image.new("RGBA", (S, S))
    out.alpha_composite(sh, (0, 50))
    out.alpha_composite(fg)
    return out


def scaled(layer, factor):
    small = layer.resize((int(S * factor), int(S * factor)), Image.LANCZOS)
    canvas = Image.new("RGBA", (S, S))
    canvas.alpha_composite(small, ((S - small.width) // 2, (S - small.height) // 2))
    return canvas


def main(out_dir):
    os.makedirs(out_dir, exist_ok=True)
    art = with_shadow(artwork())

    full = gradient()
    full.alpha_composite(scaled(art, 1.0))
    full.convert("RGB").resize((OUT, OUT), Image.LANCZOS).save(os.path.join(out_dir, "icon.png"))

    # Adaptive icons are masked to circles/squircles: keep art in the safe zone.
    scaled(art, 0.72).resize((OUT, OUT), Image.LANCZOS).save(os.path.join(out_dir, "icon_foreground.png"))
    gradient().convert("RGB").resize((OUT, OUT), Image.LANCZOS).save(os.path.join(out_dir, "icon_background.png"))

    # Themed icon: a single-colour silhouette (Android tints it).
    silhouette = scaled(artwork(), 0.72).split()[3]
    mono = Image.new("RGBA", (S, S), (255, 255, 255, 0))
    mono.putalpha(silhouette)
    mono.resize((OUT, OUT), Image.LANCZOS).save(os.path.join(out_dir, "icon_monochrome.png"))
    print("icons written to", out_dir)


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "assets/icon")
