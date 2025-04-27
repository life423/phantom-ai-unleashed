from PIL import Image
import os

# Ensure output directory exists
os.makedirs("assets/images", exist_ok=True)

# Create player sprite (green rectangle)
player_img = Image.new('RGB', (32, 32), color=(76, 175, 80))  # Green color
player_img.save('assets/images/player_sprite.png')
print("Created player_sprite.png")

# Create shadow sprite (dark gray rectangle)
shadow_img = Image.new('RGBA', (32, 32), color=(50, 50, 50, 178))  # Dark gray with transparency
shadow_img.save('assets/images/shadow_effect.png')
print("Created shadow_effect.png")

print("Images created successfully!")
