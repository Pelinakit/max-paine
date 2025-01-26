extends Node
var player_score = 0
var player_health = 100
var level_number = 1

# For continuous score calculation
var score_per_second = 0.0
const BASE_SIZE_PENALTY = -10 # Points per second penalty for base size yeasts
const WIN_SCORE = 1000

var party_trumpet = preload("res://assets/sounds/party_trumpet.wav")

func reset_game():
	player_score = 0
	player_health = 100
	level_number = 1
	score_per_second = 0.0

func transition_to_main_menu():
	if player_score >= WIN_SCORE:
		var audio = AudioStreamPlayer.new()
		audio.stream = party_trumpet
		audio.volume_db = -20.0
		add_child(audio)
		audio.play()
		audio.finished.connect(func(): audio.queue_free())
	
	var timer = get_tree().create_timer(3.0)
	timer.timeout.connect(func():
		get_tree().paused = false
		reset_game()
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	)

func calculate_score_rate(yeasts: Array) -> float:
	var total = 0.0
	var base_size_count = 0
	
	for node in yeasts:
		# Only count nodes that are yeasts (have both take_damage and current_size)
		if node.has_method("take_damage") and "current_size" in node:
			# Count yeasts at base size for penalty
			if node.current_size <= 1.0:
				base_size_count += 1
			else:
				# Add points for growth beyond base size
				var growth = node.current_size - 1.0
				total += growth * 100
	
	# Apply penalty for base size yeasts and store the true rate
	score_per_second = total + base_size_count * BASE_SIZE_PENALTY
	
	# Only update score if we won't go negative
	if player_score + score_per_second >= 0:
		player_score += score_per_second
		# Check for win condition
		if player_score >= WIN_SCORE:
			player_score = WIN_SCORE
			get_tree().paused = true
			transition_to_main_menu()
	elif player_score > 0:
		# If we would go negative, just go to zero
		player_score = 0
	
	# Return the true rate (can be negative)
	return score_per_second
