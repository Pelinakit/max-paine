extends Area2D

@export var base_speed = 300.0 # Base speed that will be modified by size
@export var lift_force = -400.0 # Force to counteract player gravity
@export var wobble_amplitude = 30.0 # Base amplitude for wobble
@export var wobble_frequency = 2.0 # Base frequency for wobble
@export var drag_coefficient = 0.5 # How quickly lift force diminishes with speed
@export var min_lift_factor = 0.4 # Minimum lift force multiplier (0.0 to 1.0)
@export var attachment_duration = 2.0 # How long the bubble stays attached

var speed = base_speed
var attached_to_player = false
var player_ref: CharacterBody2D = null
var initial_x = 0.0 # Store initial x position for wobble
var time_elapsed = 0.0 # Track time for wobble movement
var attachment_time = 0.0 # Track how long the bubble has been attached
# Secondary wobble parameters for more natural movement
var secondary_freq: float
var amplitude_variation_freq: float
var phase_offset: float

func _ready():
	if !body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if !area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	# Speed is inversely proportional to scale
	# Smaller bubbles move faster
	speed = base_speed / scale.x
	initial_x = position.x
	
	# Randomize wobble parameters for each bubble
	time_elapsed = randf() * PI * 2
	secondary_freq = randf_range(0.3, 0.7) * wobble_frequency
	amplitude_variation_freq = randf_range(0.2, 0.4)
	phase_offset = randf() * PI * 2

func _physics_process(delta):
	if attached_to_player and player_ref:
		# Update attachment time
		attachment_time += delta
		# Follow player position
		position = player_ref.position
	else:
		# Update time for wobble
		time_elapsed += delta
		
		# Primary wobble
		var main_wobble = sin(time_elapsed * wobble_frequency + phase_offset)
		# Secondary slower wobble
		var secondary_wobble = sin(time_elapsed * secondary_freq)
		# Amplitude variation over time
		var amplitude_variation = 1.0 + 0.3 * sin(time_elapsed * amplitude_variation_freq)
		
		# Combine all movements
		var total_wobble = (main_wobble + 0.3 * secondary_wobble) * amplitude_variation
		var wobble_offset = total_wobble * (wobble_amplitude * scale.x)
		
		# Update position with both vertical and horizontal movement
		position.x = initial_x + wobble_offset
		position.y -= speed * delta

func get_lift_factor():
	# Return a value from 1.0 to 0.0 based on how long the bubble has been attached
	return maxf(0.0, 1.0 - (attachment_time / attachment_duration))

func _on_body_entered(body: Node2D):
	if body is CharacterBody2D and !attached_to_player:
		attach_to_player(body)

func attach_to_player(player: CharacterBody2D):
	attached_to_player = true
	player_ref = player
	attachment_time = 0.0
	# Register with player's bubble tracking
	player_ref.add_bubble(self)
	# Disable collision layer when attached
	collision_layer = 0
	# Start despawn timer
	var timer = get_tree().create_timer(attachment_duration)
	timer.timeout.connect(func(): detach_from_player())

func detach_from_player():
	if attached_to_player and player_ref:
		player_ref.remove_bubble(self)
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	if !attached_to_player:
		queue_free()

func _on_area_entered(area: Area2D):
	if area.is_in_group("sugar"):
		take_damage()

func take_damage():
	if !attached_to_player:
		queue_free()
	else:
		detach_from_player()

func _exit_tree():
	# Make sure we remove ourselves from player when being freed
	if attached_to_player and player_ref:
		player_ref.remove_bubble(self)
