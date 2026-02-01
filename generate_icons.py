#!/usr/bin/env python3
"""
Generate App Icons for Beleg-Renamer
Creates "BR" text on a vibrant red background with rounded corners
"""

from PIL import Image, ImageDraw, ImageFont
import os

# Icon sizes needed for macOS (actual pixel sizes)
ICON_SIZES = [
    (16, "icon_16x16.png"),
    (32, "icon_16x16@2x.png"),
    (32, "icon_32x32.png"),
    (64, "icon_32x32@2x.png"),
    (128, "icon_128x128.png"),
    (256, "icon_128x128@2x.png"),
    (256, "icon_256x256.png"),
    (512, "icon_256x256@2x.png"),
    (512, "icon_512x512.png"),
    (1024, "icon_512x512@2x.png"),
]

# Colors
RED_BG = (220, 38, 38)  # Vibrant red (#DC2626)
WHITE_TEXT = (255, 255, 255)

def get_font(font_size):
    """Get a suitable font, trying multiple options."""
    font_paths = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        "/Library/Fonts/Arial Bold.ttf",
        "/System/Library/Fonts/Supplemental/Verdana Bold.ttf",
        "/System/Library/Fonts/Geneva.ttf",
    ]

    for font_path in font_paths:
        if os.path.exists(font_path):
            try:
                return ImageFont.truetype(font_path, font_size)
            except Exception as e:
                print(f"  Warning: Could not load {font_path}: {e}")
                continue

    # Try TTC fonts with index
    ttc_fonts = [
        ("/System/Library/Fonts/Avenir Next.ttc", 0),
        ("/System/Library/Fonts/Avenir.ttc", 0),
    ]

    for font_path, index in ttc_fonts:
        if os.path.exists(font_path):
            try:
                return ImageFont.truetype(font_path, font_size, index=index)
            except Exception as e:
                print(f"  Warning: Could not load {font_path}: {e}")
                continue

    return None

def create_icon(size, output_path):
    """Create a single icon at the specified size."""
    # Create image with red background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Draw rounded rectangle background
    corner_radius = max(int(size * 0.22), 2)  # macOS style ~22% corner radius
    draw.rounded_rectangle(
        [(0, 0), (size - 1, size - 1)],
        radius=corner_radius,
        fill=RED_BG
    )

    # Calculate font size (about 50% of icon size for "BR")
    font_size = max(int(size * 0.48), 8)  # Minimum 8pt

    font = get_font(font_size)

    if font is None:
        print(f"  Warning: No suitable font found for size {size}, using fallback")
        # Create a simple icon without text as fallback
        img.save(output_path, 'PNG')
        print(f"Created: {output_path} ({size}x{size}) - NO TEXT (fallback)")
        return

    # Draw "BR" text centered
    text = "BR"

    # Get text bounding box
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]

    # Center the text (with slight vertical adjustment for visual centering)
    x = (size - text_width) // 2 - bbox[0]
    y = (size - text_height) // 2 - bbox[1] - int(size * 0.02)  # Slight upward adjustment

    # Draw the text
    draw.text((x, y), text, fill=WHITE_TEXT, font=font)

    # Save
    img.save(output_path, 'PNG')
    print(f"Created: {output_path} ({size}x{size})")

def main():
    # Output directory
    output_dir = "/Users/wernerneu/Desktop/Development/Beleg-Renamer/BelegRenamer/BelegRenamer/Assets.xcassets/AppIcon.appiconset"

    print("Generating Beleg-Renamer App Icons...")
    print(f"Output directory: {output_dir}")
    print()

    # Generate all icon sizes
    for size, filename in ICON_SIZES:
        output_path = os.path.join(output_dir, filename)
        create_icon(size, output_path)

    print()
    print("All icons generated successfully!")

if __name__ == "__main__":
    main()
