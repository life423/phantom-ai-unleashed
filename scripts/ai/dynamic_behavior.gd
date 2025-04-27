extends Node

# This class stores and analyzes player actions to adapt the Shadow AI's behavior

# Storage for player action patterns
var action_history = []
var max_history_size = 50

# Pattern recognition thresholds
var pattern_threshold = 3  # Number of repetitive actions to detect a pattern
var movement_patterns = {}

func _ready():
	print("Dynamic Behavior Module initialized")

func record_action(action_type, action_data):
	"""
	Records player actions to analyze for patterns
	action_type: String (e.g., "move", "jump", "attack")
	action_data: Dictionary with relevant data for the action
	"""
	# Add timestamp to action data
	action_data["timestamp"] = Time.get_ticks_msec()
	
	# Create a complete action record
	var action = {
		"type": action_type,
		"data": action_data
	}
	
	# Add to history and trim if needed
	action_history.append(action)
	if action_history.size() > max_history_size:
		action_history.pop_front()
	
	# Analyze for patterns after each new action
	analyze_patterns()

func analyze_patterns():
	"""
	Looks for patterns in the player's recent actions
	"""
	movement_patterns.clear()
	
	# Simple pattern detection - count action types
	var action_counts = {}
	
	for action in action_history:
		var type = action["type"]
		if not action_counts.has(type):
			action_counts[type] = 0
		action_counts[type] += 1
	
	# Identify dominant actions
	for type in action_counts:
		if action_counts[type] >= pattern_threshold:
			movement_patterns[type] = action_counts[type]
	
	# If patterns detected, notify
	if not movement_patterns.empty():
		print("Detected patterns: ", movement_patterns)
		return movement_patterns

func get_adapted_behavior():
	"""
	Returns a behavior adapted to counter the player's patterns
	"""
	if movement_patterns.empty():
		return "random"  # Default behavior
	
	# Example: If player jumps a lot, shadow will focus on aerial movements
	if movement_patterns.has("jump") and movement_patterns["jump"] > pattern_threshold:
		return "aerial"
		
	# If player moves right a lot, focus on that direction
	if movement_patterns.has("move_right") and movement_patterns["move_right"] > pattern_threshold:
		return "chase_right"
		
	# If player moves left a lot, focus on that direction
	if movement_patterns.has("move_left") and movement_patterns["move_left"] > pattern_threshold:
		return "chase_left"
	
	return "responsive"  # General adaptive behavior
