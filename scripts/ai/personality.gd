extends Node

# Enum for shadow AI personality/mood states
enum MoodState {
	MISCHIEVOUS,
	HELPFUL,
	ANTAGONISTIC
}

# Current mood and properties
var current_mood = MoodState.MISCHIEVOUS
var mood_duration_min = 10  # Minimum time to maintain a mood (seconds)
var mood_duration_max = 30  # Maximum time to maintain a mood (seconds)
var current_mood_timer = 0
var mood_transition_chance = 0.3  # Chance of mood changing when triggered

# Mood-specific properties
var mood_properties = {
	MoodState.MISCHIEVOUS: {
		"color": Color(0.7, 0.3, 0.9, 0.7),  # Purple tint
		"obstacle_chance": 0.6,  # Higher chance to create obstacles
		"hint_chance": 0.2,     # Low chance to provide hints
		"follow_distance": 50,   # Maintains some distance while following
		"description": "Mischievous"
	},
	MoodState.HELPFUL: {
		"color": Color(0.3, 0.7, 0.4, 0.7),  # Green tint
		"obstacle_chance": 0.1,  # Very low chance to create obstacles
		"hint_chance": 0.8,     # High chance to provide helpful hints
		"follow_distance": 30,   # Stays close to help
		"description": "Helpful"
	},
	MoodState.ANTAGONISTIC: {
		"color": Color(0.8, 0.2, 0.2, 0.7),  # Red tint
		"obstacle_chance": 0.9,  # Very high chance to create obstacles
		"hint_chance": 0.05,    # Almost never provides hints
		"follow_distance": 70,   # Keeps distance for surprise attacks
		"description": "Antagonistic"
	}
}

func _ready():
	print("Personality module initialized with mood: ", get_mood_name())
	randomize()
	set_random_mood_timer()

func _process(delta):
	# Update mood timer and potentially change mood
	current_mood_timer -= delta
	if current_mood_timer <= 0:
		change_random_mood()
		set_random_mood_timer()

func set_random_mood_timer():
	# Set a random duration for the current mood
	current_mood_timer = randf_range(mood_duration_min, mood_duration_max)

func change_mood(new_mood):
	# Change to a specific mood
	if new_mood != current_mood:
		current_mood = new_mood
		print("Mood changed to: ", get_mood_name())
		return true
	return false

func change_random_mood():
	# Randomly select a new mood (different from current)
	var moods = MoodState.values()
	var new_mood = current_mood
	
	# Make sure we pick a different mood
	while new_mood == current_mood:
		new_mood = moods[randi() % moods.size()]
	
	return change_mood(new_mood)

func trigger_mood_event(trigger_type):
	"""
	External events can trigger potential mood changes
	trigger_type: String describing the event (e.g. "player_died", "level_complete")
	"""
	# Check if this event will cause a mood change
	if randf() <= mood_transition_chance:
		change_random_mood()
		return true
	return false

func get_current_properties():
	# Return the properties for the current mood
	return mood_properties[current_mood]

func get_mood_name():
	# Return the string name of the current mood
	return mood_properties[current_mood]["description"]

func will_create_obstacle():
	# Based on current mood, determine if should create an obstacle
	return randf() <= mood_properties[current_mood]["obstacle_chance"]

func will_provide_hint():
	# Based on current mood, determine if should provide a hint
	return randf() <= mood_properties[current_mood]["hint_chance"]

func get_mood_color():
	# Return the color associated with the current mood
	return mood_properties[current_mood]["color"]
