extends CharacterBody2D

@export var speed = 400
@export var left_limit = -1000
@export var right_limit = 1000

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
