extends CharacterBody2D

@export var speed = 400
@export var left_limit = -1000
@export var right_limit = 1000

var Sugar = preload("res://scenes/objects/Sugar.tscn")
@export var shoot_cooldown = 0.2
var can_shoot = true

func _ready():
	$Camera2D.make_current()

func _physics_process(_delta):
	var input_direction = 0
	
	if Input.is_action_pressed("move_left"):
		input_direction -= 1
	elif Input.is_action_pressed("move_right"):
		input_direction += 1
	else:
		input_direction = 0
		
	velocity.x = input_direction * speed
	move_and_slide()
	
	position.x = clamp(position.x, left_limit, right_limit)
	
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

func shoot():
	can_shoot = false
	var sugar = Sugar.instantiate()
	sugar.position = position + Vector2(0, 20) # Spawn slightly below the player
	get_parent().add_child(sugar)
	
	# Start cooldown timer
	var timer = get_tree().create_timer(shoot_cooldown)
	timer.timeout.connect(func(): can_shoot = true)
