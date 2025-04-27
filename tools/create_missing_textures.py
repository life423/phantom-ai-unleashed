import os

from PIL import Image, ImageDraw


def create_colored_square(filepath, color=(0, 255, 0), size=(32, 32)):
    """Create a simple colored square image"""
    # Ensure directory exists
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    
    # Create image with specified color
    img = Image.new('RGBA', size, color)
    draw = ImageDraw.Draw(img)
    
    # Add border
    draw.rectangle((0, 0, size[0]-1, size[1]-1), outline=(0, 0, 0))
    
    # Save the image
    img.save(filepath)
    print(f"Created {filepath}")

# Create required textures
create_colored_square("../assets/images/player_sprite.png", (0, 200, 0))  # Green player
create_colored_square("../assets/images/shadow_effect.png", (50, 50, 50, 180), (32, 32))  # Semi-transparent shadow