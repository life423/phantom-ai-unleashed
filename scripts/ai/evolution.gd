extends Node

# This module handles the evolution and learning aspects of the Shadow AI

# Learning parameters
var learning_rate = 0.05  # How quickly the AI adapts to new strategies
var exploration_rate = 0.2  # Chance to try a random action vs. learned action
var discount_factor = 0.9  # How much future rewards are valued vs immediate

# State tracking
var state_action_values = {}  # Q-values for state-action pairs
var previous_state = null
var previous_action = null
var total_actions = 0
var successful_actions = 0
var evolution_level = 0  # Represents how evolved the AI has become (0-10)

# Evolution thresholds
var actions_per_evolution = 50  # Actions needed before evolution can occur
var success_rate_threshold = 0.6  # Success rate needed to evolve

func _ready():
	print("Evolution module initialized at level: ", evolution_level)
	randomize()

func update_from_reward(state, action, reward, next_state):
	"""
	Simple Q-learning update function
	state: string representing the current state
	action: string representing the action taken
	reward: float value reward received
	next_state: string representing the resulting state
	"""
	# Record this action
	total_actions += 1
	if reward > 0:
		successful_actions += 1
	
	# Initialize state-action pair if not seen before
	var state_key = state.hash()
	if not state_action_values.has(state_key):
		state_action_values[state_key] = {}
	
	if not state_action_values[state_key].has(action):
		state_action_values[state_key][action] = 0.0
	
	# Calculate the max Q-value for the next state
	var max_next_value = 0.0
	var next_state_key = next_state.hash()
	
	if state_action_values.has(next_state_key):
		var next_actions = state_action_values[next_state_key].keys()
		if next_actions.size() > 0:
			max_next_value = -INF
			for next_action in next_actions:
				max_next_value = max(max_next_value, state_action_values[next_state_key][next_action])
	
	# Q-learning update formula
	var current_value = state_action_values[state_key][action]
	var new_value = current_value + learning_rate * (reward + discount_factor * max_next_value - current_value)
	state_action_values[state_key][action] = new_value
	
	# Store this state-action pair as the previous one
	previous_state = state
	previous_action = action
	
	# Check for possible evolution
	check_evolution()
	
	return new_value

func choose_action(state, available_actions):
	"""
	Choose an action based on the current state, using exploration vs exploitation
	state: string representing the current state
	available_actions: array of possible actions that can be taken
	"""
	# If no actions available, return null
	if available_actions.size() == 0:
		return null
	
	# Random exploration with probability exploration_rate
	if randf() < exploration_rate:
		return available_actions[randi() % available_actions.size()]
	
	# Otherwise, choose the best action based on learned values
	var state_key = state.hash()
	if not state_action_values.has(state_key):
		# If state not seen before, initialize and choose random action
		state_action_values[state_key] = {}
		return available_actions[randi() % available_actions.size()]
	
	# Find the best action with highest Q-value
	var best_action = null
	var best_value = -INF
	
	for action in available_actions:
		if not state_action_values[state_key].has(action):
			state_action_values[state_key][action] = 0.0
			
		if state_action_values[state_key][action] > best_value:
			best_value = state_action_values[state_key][action]
			best_action = action
	
	return best_action

func check_evolution():
	"""
	Check if the AI should evolve based on performance
	"""
	# Need minimum number of actions before evolving
	if total_actions < actions_per_evolution:
		return false
	
	# Calculate success rate
	var success_rate = float(successful_actions) / total_actions
	
	# If meeting the threshold and not at max evolution
	if success_rate >= success_rate_threshold and evolution_level < 10:
		evolve()
		return true
	
	return false

func evolve():
	"""
	Increase the evolution level and adjust parameters
	"""
	evolution_level += 1
	print("Shadow AI evolved to level ", evolution_level)
	
	# Reduce exploration as we evolve (become more confident in learned strategies)
	exploration_rate = max(0.05, exploration_rate - 0.02)
	
	# Increase learning rate slightly to adapt faster
	learning_rate = min(0.2, learning_rate + 0.01)
	
	# Reset counters for next evolution
	total_actions = 0
	successful_actions = 0
	
	return evolution_level

func get_evolution_level():
	return evolution_level

func get_evolution_progress():
	# Returns progress toward next evolution (0.0 to 1.0)
	if total_actions < actions_per_evolution:
		return float(total_actions) / actions_per_evolution
	return 1.0
