extends Node2D

@onready var enemies_container = $GameplayLayer/Enemies
var Yeast = preload("res://scenes/enemies/Yeast.tscn")
var score_update_timer: Timer

func _ready():
	# Position floor at bottom of background plus 40px
	var bg_sprite = $Background/Sprite2D
	var floor_node = $Background/Floor
	if bg_sprite and bg_sprite.texture:
		var bg_height = bg_sprite.texture.get_height()
		floor_node.position.y = bg_height / 2 - 40

	# Position ceiling at top of background minus 40px
	var ceiling_node = $Background/Ceiling
	if ceiling_node:
		var bg_height = bg_sprite.texture.get_height()
		ceiling_node.position.y = -bg_height / 2 + 40
	
	spawn_yeasts()
	setup_score_timer()

func setup_score_timer():
	score_update_timer = Timer.new()
	add_child(score_update_timer)
	score_update_timer.wait_time = 1.0 # Update score every second
	score_update_timer.timeout.connect(update_score)
	score_update_timer.start()

func update_score():
	var yeasts = enemies_container.get_children()
	# Let Global handle both rate calculation and score update
	Global.calculate_score_rate(yeasts)

func spawn_yeasts():
	# Calculate screen dimensions
	var viewport_size = get_viewport_rect().size
	var spawn_width = viewport_size.x * 0.8 # Use 80% of screen width
	
	# Get floor position for spawning yeasts
	var bg_sprite = $Background/Sprite2D
	var spawn_y = 0
	if bg_sprite and bg_sprite.texture:
		spawn_y = bg_sprite.texture.get_height() / 2 - 80 # Same as floor position
	
	# Adjust properties based on level
	var base_size = 1.0 + (Global.level_number - 1) * 0.1 # Slightly bigger each level
	var max_size = 2.0 + (Global.level_number - 1) * 0.2 # Can grow bigger each level
	
	# Spawn 4 yeasts
	for i in range(4):
		var yeast = Yeast.instantiate()
		var x_pos = -spawn_width / 2 + (spawn_width / 3) * i
		yeast.position = Vector2(x_pos, spawn_y)
		yeast.current_size = base_size
		yeast.max_size = max_size
		enemies_container.add_child(yeast)
