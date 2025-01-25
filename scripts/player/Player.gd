extends CharacterBody2D

@export var speed = 400.0
@export var gravity = 200.0
@export var drag_coefficient = 0.2
@export var terminal_velocity = 300.0
@export var left_limit = -1000
@export var right_limit = 1000

var Sugar = preload("res://scenes/objects/Sugar.tscn")
@export var shoot_cooldown = 0.2
var can_shoot = true

func _ready():
	$Camera2D.make_current()
	
	# Get collision shape height and set pivot point at bottom
	var collision_height = $CollisionShape2D.shape.size.y
	var offset = Vector2(0, -collision_height / 2)
	
	# Move all child nodes up by half the collision height
	for child in get_children():
		if child is CollisionShape2D:
			# Keep the x offset for collision shape
			child.position = Vector2(child.position.x, offset.y)
		else:
			child.position = offset

func _physics_process(delta):
	var input_direction = 0.0
	
	if Input.is_action_pressed("move_left"):
		input_direction -= 1.0
	elif Input.is_action_pressed("move_right"):
		input_direction += 1.0
	else:
		input_direction = 0.0
		
	# Apply horizontal movement with drag
	var target_speed = input_direction * speed
	velocity.x = lerp(velocity.x, target_speed, drag_coefficient)
	
	# Apply gravity with drag and terminal velocity
	velocity.y += gravity * delta
	velocity.y = lerp(velocity.y, terminal_velocity, drag_coefficient * delta)
	velocity.y = minf(velocity.y, terminal_velocity)
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider.is_in_group("floor") or collider.is_in_group("ceiling"):
			game_over()
	
	# Only clamp horizontal position
	position.x = clamp(position.x, left_limit, right_limit)
	
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

func game_over():
	get_tree().paused = true
	Global.player_health = 0

func shoot():
	can_shoot = false
	var sugar = Sugar.instantiate()
	sugar.position = position + Vector2(0, 20) # Spawn slightly below the player
	get_parent().add_child(sugar)
	
	# Start cooldown timer
	var timer = get_tree().create_timer(shoot_cooldown)
	timer.timeout.connect(func(): can_shoot = true)
