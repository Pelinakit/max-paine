extends CharacterBody2D

@export var speed = 400.0
@export var gravity = 200.0
@export var drag_coefficient = 0.2
@export var terminal_velocity = 300.0
@export var terminal_velocity_with_bubbles = 100.0 # Lower terminal velocity when rising with bubbles
@export var left_limit = -1000
@export var right_limit = 1000
@export var slope_slide_speed = 200.0
@export var wall_bounce = 0.3
@export var base_lift_per_bubble = -400.0 # Much stronger lift force
@export var diminishing_factor = 0.05 # Even less diminishing returns

var Sugar = preload("res://scenes/objects/Sugar.tscn")
var slide_whistle = preload("res://assets/sounds/slide_whistle.wav")
@export var shoot_cooldown = 0.3
var can_shoot = true
var wall_normal = Vector2.ZERO
var attached_bubbles = []

func _ready():
	$Camera2D.make_current()
	
	# Get collision shape height and set pivot point at bottom
	var collision_height = $CollisionShape2D.shape.height
	var offset = Vector2(0, -collision_height / 2)
	
	# Move all child nodes up by half the collision height
	for child in get_children():
		if child is CollisionShape2D:
			# Keep the x offset for collision shape
			child.position = Vector2(child.position.x, offset.y)
		else:
			child.position = offset

func add_bubble(bubble):
	attached_bubbles.append(bubble)

func remove_bubble(bubble):
	attached_bubbles.erase(bubble)

func get_current_lift():
	var bubble_count = attached_bubbles.size()
	if bubble_count == 0:
		return 0.0
	
	# Calculate diminishing returns for each additional bubble
	# Each subsequent bubble provides less lift
	var total_lift = 0.0
	for i in range(bubble_count):
		var bubble = attached_bubbles[i]
		var time_factor = bubble.get_lift_factor() # Get time-based diminishing factor
		var stack_factor = 1.0 / (1.0 + i * diminishing_factor) # Stack-based diminishing factor
		total_lift += base_lift_per_bubble * time_factor * stack_factor
	
	return total_lift

func _physics_process(delta):
	var input_direction = 0.0
	
	if Input.is_action_pressed("move_left"):
		input_direction -= 1.0
	elif Input.is_action_pressed("move_right"):
		input_direction += 1.0
	else:
		input_direction = 0.0
	
	# Reset wall normal if not touching wall
	if wall_normal != Vector2.ZERO and input_direction * wall_normal.x > 0:
		wall_normal = Vector2.ZERO
		
	# Apply horizontal movement with drag
	var target_speed = input_direction * speed
	velocity.x = lerp(velocity.x, target_speed, drag_coefficient)
	
	# Apply gravity with lift from bubbles
	var current_lift = get_current_lift()
	velocity.y += (gravity + current_lift) * delta
	
	# Use different terminal velocity based on movement direction
	var current_terminal = terminal_velocity
	if current_lift != 0 and velocity.y < 0: # If we have bubbles and are moving upward
		current_terminal = terminal_velocity_with_bubbles
	
	# Only apply terminal velocity when moving downward or if we're not rising with bubbles
	if velocity.y > 0 or current_lift == 0:
		velocity.y = lerp(velocity.y, current_terminal, drag_coefficient * delta)
		velocity.y = minf(velocity.y, current_terminal)
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider.is_in_group("floor") or collider.is_in_group("ceiling"):
			game_over()
		elif collider.is_in_group("bottle_wall"):
			wall_normal = collision.get_normal()
			
			# Only apply slide if moving into the wall
			if input_direction * wall_normal.x < 0:
				# Calculate slide direction (perpendicular to normal, pointing downward)
				var slide_direction = Vector2(-wall_normal.y, wall_normal.x) * sign(wall_normal.x)
				velocity = slide_direction * slope_slide_speed
				
				# Add slight horizontal push away from wall
				velocity.x += wall_normal.x * speed * wall_bounce
			else:
				# Just bounce off the wall if not actively moving into it
				velocity = velocity.bounce(wall_normal) * wall_bounce
	
	# Only clamp horizontal position
	position.x = clamp(position.x, left_limit, right_limit)
	
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

func game_over():
	get_tree().paused = true
	Global.player_health = 0
	
	# Add delayed width scaling with sound
	var timer = get_tree().create_timer(2.0)
	timer.timeout.connect(func():
		scale.x = 2.0
		var audio = AudioStreamPlayer.new()
		audio.stream = slide_whistle
		audio.volume_db = -20.0
		add_child(audio)
		audio.play()
		audio.finished.connect(func(): audio.queue_free())
		Global.transition_to_main_menu()
	)

func shoot():
	can_shoot = false
	var sugar = Sugar.instantiate()
	sugar.position = position + Vector2(0, 20) # Spawn slightly below the player
	get_parent().add_child(sugar)
	
	# Start cooldown timer
	var timer = get_tree().create_timer(shoot_cooldown)
	timer.timeout.connect(func(): can_shoot = true)
