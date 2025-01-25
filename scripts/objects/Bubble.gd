extends Area2D

@export var speed = 200.0
@export var drag_coefficient = 0.2
@export var terminal_velocity = -300.0 # Negative because moving upward

var velocity = Vector2.ZERO

func _physics_process(delta):
	# Apply upward movement with drag and terminal velocity
	velocity.y += -speed * delta # Negative for upward movement
	velocity.y = lerp(velocity.y, terminal_velocity, drag_coefficient * delta)
	velocity.y = maxf(velocity.y, terminal_velocity) # Cap upward speed
	
	position += velocity * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
