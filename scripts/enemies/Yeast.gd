extends CharacterBody2D

@export var growth_per_feed = 0.1
@export var max_size = 2.0
var current_size = 1.0

var Bubble = preload("res://scenes/objects/Bubble.tscn")
var can_spawn_bubble = true

func _ready():
	update_size()
	$Area2D.area_entered.connect(_on_area_entered)
	start_bubble_timer()

func take_damage():
	# In this case, "damage" is actually feeding and growing
	if current_size < max_size:
		current_size += growth_per_feed
		update_size()

func update_size():
	scale = Vector2(current_size, current_size)

func _on_area_entered(area: Area2D):
	if area.is_in_group("sugar"):
		take_damage()
		# The sugar will delete itself via its own collision handling

func start_bubble_timer():
	if !can_spawn_bubble:
		return
		
	can_spawn_bubble = false
	
	# Random time between 1 and 4 seconds
	var wait_time = randf_range(1.0, 4.0)
	var timer = get_tree().create_timer(wait_time)
	timer.timeout.connect(spawn_bubble)

func spawn_bubble():
	var bubble = Bubble.instantiate()
	# Spawn bubble from top of yeast (remember our pivot is at bottom)
	bubble.position = position + Vector2(0, -$CollisionShape2D.shape.radius * 2 * current_size)
	get_parent().add_child(bubble)
	
	can_spawn_bubble = true
	start_bubble_timer()
