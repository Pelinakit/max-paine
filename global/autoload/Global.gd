extends Node
var player_score = 0
var player_health = 100
var level_number = 1

# For continuous score calculation
var score_per_second = 0.0

func reset_game():
	player_score = 0
	player_health = 100
	level_number = 1
	score_per_second = 0.0

func calculate_score_rate(yeasts: Array) -> float:
	var total = 0.0
	for node in yeasts:
		# Only count nodes that are yeasts (have current_size property)
		if node.has_method("take_damage"): # This is unique to Yeast nodes
			total += node.current_size * 100
	return total
