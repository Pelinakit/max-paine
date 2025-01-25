extends Area2D

@export var speed = 100.0 # Constant upward speed
@export var lift_force = -400.0 # Force to counteract player gravity

var attached_to_player = false
var player_ref: CharacterBody2D = null

func _ready():
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	if attached_to_player and player_ref:
		# Follow player position
		position = player_ref.position
		# Apply lift force to player
		player_ref.velocity.y += lift_force * delta
	else:
		# Simple constant upward movement
		position.y -= speed * delta

func _on_body_entered(body: Node2D):
	if body is CharacterBody2D and !attached_to_player:
		attach_to_player(body)

func attach_to_player(player: CharacterBody2D):
	attached_to_player = true
	player_ref = player
	# Start despawn timer
	var timer = get_tree().create_timer(2.0)
	timer.timeout.connect(queue_free)

func _on_visible_on_screen_notifier_2d_screen_exited():
	if !attached_to_player:
		queue_free()
