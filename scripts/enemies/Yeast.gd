extends CharacterBody2D

@export var growth_per_feed = 0.1
@export var max_size = 2.0
@export var shrink_rate = 0.05
var current_size = 1.0

var Bubble = preload("res://scenes/objects/Bubble.tscn")
var bubble_sounds = []
var can_spawn_bubble = true

func _ready():
	# Load all bubble sounds from directory
	var dir = DirAccess.open("res://assets/sounds/bubble")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".wav"):
				bubble_sounds.append(load("res://assets/sounds/bubble/" + file_name))
			file_name = dir.get_next()
		dir.list_dir_end()
	
	update_size()
	$Area2D.area_entered.connect(_on_area_entered)
	start_bubble_timer()

func _process(delta):
	# Gradually shrink, but don't go below base size
	if current_size > 1.0:
		current_size = max(1.0, current_size - shrink_rate * delta)
		update_size()

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
	# Random size between 1x and 3x
	var bubble_scale = randf_range(1.0, 3.0)
	bubble.scale = Vector2(bubble_scale, bubble_scale)
	# Spawn bubble from top of yeast (remember our pivot is at bottom)
	bubble.position = position + Vector2(0, -$CollisionShape2D.shape.radius * 2 * current_size)
	get_parent().add_child(bubble)
	
	# Play random bubble sound
	var audio = AudioStreamPlayer.new()
	audio.stream = bubble_sounds.pick_random()
	audio.volume_db = -20.0
	add_child(audio)
	audio.play()
	audio.finished.connect(func(): audio.queue_free())
	
	can_spawn_bubble = true
	start_bubble_timer()
