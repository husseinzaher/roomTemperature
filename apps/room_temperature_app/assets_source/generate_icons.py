"""One-off script to generate Android launcher icon assets from a single
source image (see app_icon_source.png). Not part of the app build — run
manually whenever the source artwork changes.
"""

from PIL import Image, ImageDraw
import os

ROOT = os.path.dirname(os.path.abspath(__file__))
ANDROID_APP = os.path.join(ROOT, "..", "android", "app")
SOURCE = os.path.join(ROOT, "app_icon_source.png")

LEGACY_SIZES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

# 108dp adaptive-icon canvas at each density bucket's scale factor.
FOREGROUND_SIZES = {
    "mipmap-mdpi": 108,
    "mipmap-hdpi": 162,
    "mipmap-xhdpi": 216,
    "mipmap-xxhdpi": 324,
    "mipmap-xxxhdpi": 432,
}

# 160dp mark used on the Android launch screen.
SPLASH_SIZES = {
    "drawable-mdpi": 160,
    "drawable-hdpi": 240,
    "drawable-xhdpi": 320,
    "drawable-xxhdpi": 480,
    "drawable-xxxhdpi": 640,
}

FLAVORS = ["main", "development", "staging"]

BACKGROUND_COLOR = (10, 22, 42, 255)  # deep night-sky blue sampled from art


def circular_mask(im):
    size = im.size
    mask = Image.new("L", size, 0)
    draw = ImageDraw.Draw(mask)
    draw.ellipse((0, 0, size[0], size[1]), fill=255)
    out = im.copy()
    out.putalpha(mask)
    return out


def make_legacy(src, size):
    return src.resize((size, size), Image.LANCZOS)


def make_round(src, size):
    resized = src.resize((size, size), Image.LANCZOS)
    return circular_mask(resized)


def make_foreground(src, canvas_size):
    canvas = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    # Safe zone: keep the artwork within ~66% of the canvas so no launcher
    # mask shape (circle, squircle, rounded square) clips it.
    art_size = int(canvas_size * 0.66)
    art = src.resize((art_size, art_size), Image.LANCZOS)
    offset = ((canvas_size - art_size) // 2, (canvas_size - art_size) // 2)
    canvas.paste(art, offset, art)
    return canvas


def make_playstore(src, size=512):
    bg = Image.new("RGBA", (size, size), BACKGROUND_COLOR)
    art = src.resize((size, size), Image.LANCZOS)
    bg.paste(art, (0, 0), art)
    return bg.convert("RGB")


def main():
    src = Image.open(SOURCE).convert("RGBA")
    # Source is nearly square (1254x1254) with a tiny transparent margin;
    # normalize to an exact square.
    side = max(src.size)
    square = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    square.paste(src, ((side - src.size[0]) // 2, (side - src.size[1]) // 2))
    src = square

    for flavor in FLAVORS:
        flavor_root = os.path.join(ANDROID_APP, "src", flavor)
        if not os.path.isdir(flavor_root):
            continue

        for mipmap, size in LEGACY_SIZES.items():
            out_dir = os.path.join(flavor_root, "res", mipmap)
            os.makedirs(out_dir, exist_ok=True)
            make_legacy(src, size).save(os.path.join(out_dir, "ic_launcher.png"))
            make_round(src, size).save(
                os.path.join(out_dir, "ic_launcher_round.png")
            )

        for mipmap, size in FOREGROUND_SIZES.items():
            out_dir = os.path.join(flavor_root, "res", mipmap)
            os.makedirs(out_dir, exist_ok=True)
            make_foreground(src, size).save(
                os.path.join(out_dir, "ic_launcher_foreground.png")
            )

        # Remove the old vector foreground drawable now that a PNG mipmap
        # foreground is used instead.
        old_vector = os.path.join(
            flavor_root, "res", "drawable", "ic_launcher_foreground.xml"
        )
        if os.path.exists(old_vector):
            os.remove(old_vector)

        # Point the adaptive-icon XML at the new PNG mipmap foreground.
        for xml_name in ("ic_launcher.xml", "ic_launcher_round.xml"):
            xml_path = os.path.join(
                flavor_root, "res", "mipmap-anydpi-v26", xml_name
            )
            if os.path.exists(xml_path):
                with open(xml_path, "w") as f:
                    f.write(
                        '<?xml version="1.0" encoding="utf-8"?>\n'
                        '<adaptive-icon xmlns:android='
                        '"http://schemas.android.com/apk/res/android">\n'
                        '    <background android:drawable='
                        '"@color/ic_launcher_background"/>\n'
                        '    <foreground android:drawable='
                        '"@mipmap/ic_launcher_foreground"/>\n'
                        "</adaptive-icon>\n"
                    )

        # Update the flat background color to match the artwork.
        color_path = os.path.join(
            flavor_root, "res", "values", "ic_launcher_background.xml"
        )
        if os.path.exists(color_path):
            hex_color = "#FF{:02X}{:02X}{:02X}".format(*BACKGROUND_COLOR[:3])
            with open(color_path, "w") as f:
                f.write(
                    '<?xml version="1.0" encoding="utf-8"?>\n'
                    "<resources>\n"
                    f'    <color name="ic_launcher_background">{hex_color}</color>\n'
                    "</resources>\n"
                )

        playstore_path = os.path.join(flavor_root, "ic_launcher-playstore.png")
        if os.path.exists(os.path.dirname(playstore_path)) or True:
            os.makedirs(os.path.dirname(playstore_path), exist_ok=True)
            make_playstore(src).save(playstore_path)

        for drawable, size in SPLASH_SIZES.items():
            out_dir = os.path.join(flavor_root, "res", drawable)
            os.makedirs(out_dir, exist_ok=True)
            src.resize((size, size), Image.LANCZOS).save(
                os.path.join(out_dir, "splash_logo.png")
            )

        print(f"done: {flavor}")

    branding_dir = os.path.join(ROOT, "..", "assets", "branding")
    os.makedirs(branding_dir, exist_ok=True)
    src.resize((512, 512), Image.LANCZOS).save(
        os.path.join(branding_dir, "app_logo.png")
    )
    print("done: flutter branding logo")


if __name__ == "__main__":
    main()
