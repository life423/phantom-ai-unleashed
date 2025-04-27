extends Node2D

# Main script that controls the shadow AI behavior
# It integrates the three modular components:
# 1. Dynamic Behavior - adapts to player patterns
# 2. Personality - manages different moods/states
# 3. Evolution - handles learning and improvement over time

# References to AI modules
var dynamic_behavior
var personality
var evolution

# Shadow AI state
var active = true
var follow_player = true
var target_position = Vector2.ZERO
var follow_distance = 40
var speed = 150
var action_state = "follow"  # follow, assist, obstruct, idle

# AI observation frequency
var observation_timer = 0
var observation_interval = 0.5  # seconds between observations

func _ready():
	print("Shadow AI initialized")
	
	# Initialize the AI modules
	dynamic_behavior = load("res://scripts/ai/dynamic_behavior.gd").new()
	add_child(dynamic_behavior)
	
	personality = load("res://scripts/ai/personality.gd").new()
	add_child(personality)
	
	evolution = load("res://scripts/ai/evolution.gd").new()
	add_child(evolution)
	
	# Apply initial mood color to shadow sprite
	if has_node("Sprite"):
		$Sprite.modulate = personality.get_mood_color()

func _process(delta):
	if not active:
		return
		
	# Periodically observe the player
	observation_timer += delta
	if observation_timer >= observation_interval:
		observe_player()
		observation_timer = 0
	
	# Update the shadow position based on current action state
	update_position(delta)
	
	# Update sprite appearance based on current mood
	update_appearance()

func observe_player():
	# Get player data for analysis
	var player = get_parent()
	if not player:
		return
		
	# Record player's position and velocity for dynamic behavior analysis
	var player_data = {
		"position": player.global_position,
		"velocity": player.velocity if "velocity" in player else Vector2.ZERO
	}
	
	# Determine what kind of action the player is taking
	var action_type = "idle"
	if player_data.velocity.x > 0:
		action_type = "move_right"
	elif player_data.velocity.x < 0:
		action_type = "move_left"
	if player_data.velocity.y < 0:
		action_type = "jump"
	
	# Feed this data to the dynamic behavior module
	dynamic_behavior.record_action(action_type, player_data)
	
	# Get adapted behavior based on player patterns
	var behavior = dynamic_behavior.get_adapted_behavior()
	
	# Choose AI action based on personality and behavior
	choose_action(behavior)
	
	# Potentially evolve the AI and update the state
	var state = {"player": player_data, "behavior": behavior}
	var actions = ["follow", "assist", "obstruct", "idle"]
	
	# Let the evolution module choose the best action
	var chosen_action = evolution.choose_action(str(state), actions)
	if chosen_action:
		action_state = chosen_action
	
	# Provide feedback to evolution module
	var reward = calculate_reward()
	evolution.update_from_reward(str(state), action_state, reward, str(state))

func choose_action(behavior):
	# Based on the current personality mood and observed behavior,
	# decide what action to take
	var mood_props = personality.get_current_properties()
	
	# First, check if the mood dictates creating an obstacle
	if personality.will_create_obstacle():
		action_state = "obstruct"
		return
		
	# Next, check if should provide a hint/assist
	if personality.will_provide_hint():
		action_state = "assist"
		return
		
	# Default to following
	action_state = "follow"

func update_position(delta):
	var player = get_parent()
	if not player:
		return
		
	# Get the appropriate follow distance based on mood
	var mood_props = personality.get_current_properties()
	follow_distance = mood_props["follow_distance"]
	
	match action_state:
		"follow":
			# Follow behind the player at follow_distance
			target_position = player.global_position - Vector2(follow_distance, 0)
			
		"assist":
			# Move closer to the player to provide assistance
			target_position = player.global_position - Vector2(follow_distance * 0.5, 0)
			
		"obstruct":
			# Get in the player's way
			target_position = player.global_position + Vector2(follow_distance * 0.3, 0)
			
		"idle":
			# Stay in place
			target_position = global_position
	
	# Move toward the target position
	var direction = (target_position - global_position).normalized()
	global_position += direction * speed * delta

func update_appearance():
	if has_node("Sprite"):
		# Update the shadow's color based on mood
		$Sprite.modulate = personality.get_mood_color()

func calculate_reward():
	# Calculate a reward for the evolution system based on
	# how well the shadow AI is performing its role
	var reward = 0.0
	
	match action_state:
		"follow":
			# Reward for maintaining appropriate distance
			var player = get_parent()
			if player:
				var dist = global_position.distance_to(player.global_position)
				if dist < follow_distance * 1.2 and dist > follow_distance * 0.8:
					reward = 0.5
		
		"assist":
			# Reward for successfully assisting
			# This would ideally tie into game mechanics
			reward = 0.75
			
		"obstruct":
			# Reward for successfully obstructing
			# This would ideally tie into game mechanics
			reward = 0.6
	
	return reward
