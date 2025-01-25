extends CharacterBody2D

var speed = 200

var left_limit = -400
var right_limit = 400

func _process(delta):
	var input_direction = 0
	
	if Input.is_action_pressed("move_left"):
		input_direction -= 1
	if Input.is_action_pressed("move_right"):
		input_direction += 1
		
	position.x += input_direction * speed * delta
	
	position.x = clamp(position.x, left_limit, right_limit)
