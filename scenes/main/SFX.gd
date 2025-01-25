extends AudioStreamPlayer2D

# Preload sound files into an array
var sound_files = [
	preload("res://assets/sounds/bill please.wav"),
	preload("res://assets/sounds/bottle cap.wav"),
	preload("res://assets/sounds/champagne flutes.wav"),
	preload("res://assets/sounds/coffee.wav"),
	preload("res://assets/sounds/danja.wav"),
	preload("res://assets/sounds/dining.wav"),
	preload("res://assets/sounds/juho.wav"),
	preload("res://assets/sounds/magazine.wav"),
	preload("res://assets/sounds/menu, please.wav"),
	preload("res://assets/sounds/napkin.wav"),
	preload("res://assets/sounds/porcelain.wav"),
	preload("res://assets/sounds/pour.wav"),
	preload("res://assets/sounds/recommendation.wav"),
	preload("res://assets/sounds/red wine.wav"),
	preload("res://assets/sounds/table for two.wav"),
	preload("res://assets/sounds/reservation.wav"),
	preload("res://assets/sounds/vegetarian.wav"),
	preload("res://assets/sounds/wine glasses.wav"),
	preload("res://assets/sounds/with card.wav")
]

# Minimum and maximum delay (in seconds) between random sound events
var min_delay = 2
var max_delay = 5

# A reusable timer node for random interval execution
var timer

func _ready():
	# Initialize the timer
	timer = Timer.new()
	timer.one_shot = true  # Ensure it only triggers once at a time
	add_child(timer)
	
	# Properly connect the timer signal
	timer.timeout.connect(_on_timer_timeout)
	
	# Start the first random interval
	start_random_interval()

# Function to start the timer with a random interval
func start_random_interval():
	var random_interval = randi_range(min_delay, max_delay)
	timer.start(random_interval)

# Function to handle the timer's timeout event
func _on_timer_timeout():
	# Play a random sound
	play_random_sound()
	
	# Restart the timer with a new random interval
	start_random_interval()

# Function to play a random sound
func play_random_sound():
	var random_sound = sound_files[randi() % sound_files.size()]
	stream = random_sound
	play()
