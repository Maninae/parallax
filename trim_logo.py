import sys

try:
    from PIL import Image, ImageDraw
except ImportError:
    print("Error: Pillow is not installed. Please install it using 'pip install Pillow'")
    sys.exit(1)

def process_app_icon(input_path, output_path):
    img = Image.open(input_path).convert("RGBA")
    
    # Standard macOS app icon size is 1024x1024
    target_size = 1024
    img = img.resize((target_size, target_size), Image.Resampling.LANCZOS)
    
    # The standard corner radius for macOS/iOS app icons is approx 22.5% of the width.
    # Though technically a superellipse, a rounded rect with a 22.5% radius is standard.
    # macOS Big Sur+ actually uses ~22.6% for continuous corners.
    radius = int(target_size * 0.225)
    
    # Create an anti-aliased mask by rendering it larger then scaling down
    scale_factor = 4
    mask_size = target_size * scale_factor
    mask = Image.new("L", (mask_size, mask_size), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0, mask_size, mask_size), radius * scale_factor, fill=255)
    
    mask = mask.resize((target_size, target_size), Image.Resampling.LANCZOS)
    
    # Apply mask
    result = img.copy()
    result.putalpha(mask)
    
    result.save(output_path)
    print(f"Standard rounded Mac app icon ({target_size}x{target_size} with {radius}px radius) saved to: {output_path}")

if __name__ == '__main__':
    input_file = "Sources/parallax/Resources/AppIcon.png"
    output_file = "Sources/parallax/Resources/AppIcon_rounded.png"
    process_app_icon(input_file, output_file)
