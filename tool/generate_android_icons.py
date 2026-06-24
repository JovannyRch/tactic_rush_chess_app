#!/usr/bin/env python3
"""Generate Android launcher icons from assets/img/logo.png."""

from __future__ import annotations

import colorsys
import io
from pathlib import Path

from PIL import Image

# Paths relative to project root
PROJECT_ROOT = Path(__file__).resolve().parent.parent
LOGO_PATH = PROJECT_ROOT / "assets" / "img" / "logo.png"
RES_DIR = PROJECT_ROOT / "android" / "app" / "src" / "main" / "res"

# Android launcher icon sizes in dp/px per density
DENSITIES = {
    "mdpi": 48,
    "hdpi": 72,
    "xhdpi": 96,
    "xxhdpi": 144,
    "xxxhdpi": 192,
}

# Adaptive icon safe zone is 66dp of the 108dp canvas.
# We generate foreground layers at the standard 108dp baseline sizes.
ADAPTIVE_BASELINE = {
    "mdpi": 108,
    "hdpi": 162,
    "xhdpi": 216,
    "xxhdpi": 324,
    "xxxhdpi": 432,
}


def dominant_color(image: Image.Image) -> tuple[int, int, int]:
    """Return a pleasant dominant color for the adaptive icon background."""
    # Resize to speed up quantization
    small = image.copy().convert("RGB")
    small.thumbnail((128, 128))
    # Quantize to a small palette and pick the most common color
    palette = small.quantize(colors=8, method=Image.Quantize.MEDIANCUT)
    colors = palette.getpalette()  # type: ignore[assignment]
    counts = palette.getcolors()
    if colors is None or counts is None:
        return (0, 0, 0)

    best_count = 0
    best_rgb = (0, 0, 0)
    for count, idx in counts:
        r = colors[idx * 3]
        g = colors[idx * 3 + 1]
        b = colors[idx * 3 + 2]
        # Skip near-white and near-black so the background has some personality
        luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0
        if luminance < 0.1 or luminance > 0.9:
            continue
        if count > best_count:
            best_count = count
            best_rgb = (r, g, b)

    if best_count == 0:
        # Fallback: average color
        small = image.convert("RGB")
        r_total = g_total = b_total = 0
        pixels = list(small.getdata())
        for r, g, b in pixels:
            r_total += r
            g_total += g
            b_total += b
        n = len(pixels)
        return (r_total // n, g_total // n, b_total // n)

    return best_rgb


def make_square(src: Image.Image, size: int) -> Image.Image:
    """Create a square icon scaled to the requested size."""
    img = src.convert("RGBA")
    # Add padding so the logo doesn't touch the edges (10% padding)
    padded_size = int(size * 0.80)
    img = img.resize((padded_size, padded_size), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    offset = (size - padded_size) // 2
    canvas.paste(img, (offset, offset), img)
    return canvas


def make_round(src: Image.Image, size: int) -> Image.Image:
    """Create a circular icon with a transparent background."""
    square = make_square(src, size)
    mask = Image.new("L", (size, size), 0)
    from PIL import ImageDraw

    draw = ImageDraw.Draw(mask)
    draw.ellipse((0, 0, size - 1, size - 1), fill=255)
    result = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    result.paste(square, (0, 0), mask)
    return result


def make_adaptive_foreground(src: Image.Image, size: int) -> Image.Image:
    """Create a foreground layer that fits inside the 66dp safe zone."""
    img = src.convert("RGBA")
    # Use 66% of the 108dp canvas for the safe zone
    safe_size = int(size * 0.66)
    img = img.resize((safe_size, safe_size), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    offset = (size - safe_size) // 2
    canvas.paste(img, (offset, offset), img)
    return canvas


def color_to_hex(color: tuple[int, int, int]) -> str:
    return "#{:02x}{:02x}{:02x}".format(*color)


def main() -> None:
    if not LOGO_PATH.exists():
        raise SystemExit(f"Logo not found at {LOGO_PATH}")

    logo = Image.open(LOGO_PATH)
    # Brand background color for the adaptive icon.
    bg_hex = "#071120"

    print(f"Source logo: {logo.size}")
    print(f"Adaptive background color: {bg_hex}")

    # Standard + round icons
    for density, size in DENSITIES.items():
        folder = RES_DIR / f"mipmap-{density}"
        folder.mkdir(parents=True, exist_ok=True)
        square = make_square(logo, size)
        square.save(folder / "ic_launcher.png", "PNG")
        round_icon = make_round(logo, size)
        round_icon.save(folder / "ic_launcher_round.png", "PNG")
        print(f"  {density}: ic_launcher.png + ic_launcher_round.png ({size}x{size})")

    # Adaptive icon foreground layers
    for density, size in ADAPTIVE_BASELINE.items():
        folder = RES_DIR / f"mipmap-{density}"
        folder.mkdir(parents=True, exist_ok=True)
        foreground = make_adaptive_foreground(logo, size)
        foreground.save(folder / "ic_launcher_foreground.png", "PNG")
        print(f"  {density}: ic_launcher_foreground.png ({size}x{size})")

    # Adaptive icon XML definitions
    anydpi_folder = RES_DIR / "mipmap-anydpi-v26"
    anydpi_folder.mkdir(parents=True, exist_ok=True)
    (anydpi_folder / "ic_launcher.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        f'    <background android:drawable="@color/ic_launcher_background" />\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground" />\n'
        '</adaptive-icon>\n'
    )
    (anydpi_folder / "ic_launcher_round.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        f'    <background android:drawable="@color/ic_launcher_background" />\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground" />\n'
        '</adaptive-icon>\n'
    )
    print("  mipmap-anydpi-v26: ic_launcher.xml + ic_launcher_round.xml")

    # Background color resource
    values_folder = RES_DIR / "values"
    values_folder.mkdir(parents=True, exist_ok=True)
    (values_folder / "ic_launcher_background.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<resources>\n'
        f'    <color name="ic_launcher_background">{bg_hex}</color>\n'
        '</resources>\n'
    )
    print("  values: ic_launcher_background.xml")

    print("Android icons generated successfully.")


if __name__ == "__main__":
    main()
