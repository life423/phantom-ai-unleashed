extends Node2D

# Main game controller script

# References to key nodes
@onready var player = $Player
@onready var ui = $UI

func _ready():
	print("Phantom AI Game started")
	
	# Set initial player position
	if player:
		player.position = Vector2(400, 400)
		print("Player initialized at ", player.position)
	
	# Connect to shadow AI properties to update UI
	if player and player.has_node("Shadow"):
		var shadow = player.get_node("Shadow")
		if shadow and shadow.get("personality") and ui and ui.has_node("MoodDisplay"):
			var mood_display = ui.get_node("MoodDisplay")
			if mood_display:
				# Update UI with shadow mood information
				_update_mood_display(shadow)
	
	# Debug info
	print("Running Godot version: ", Engine.get_version_info().string)
	print("Scene tree initialized.")

func _process(_delta):
	# Update UI elements if needed
	_update_ui()

func _update_ui():
	# Update mood display if shadow AI exists
	if player and player.has_node("Shadow") and ui and ui.has_node("MoodDisplay"):
		var shadow = player.get_node("Shadow")
		if shadow and shadow.get("personality"):
			_update_mood_display(shadow)

func _update_mood_display(shadow):
	# Update the UI to show the current shadow mood
	if ui and ui.has_node("MoodDisplay"):
		var mood_display = ui.get_node("MoodDisplay")
		if shadow.get("personality"):
			var mood_name = "Unknown"
			if shadow.personality.has_method("get_mood_name"):
				mood_name = shadow.personality.get_mood_name()
			mood_display.text = "Shadow Mood: " + mood_name
