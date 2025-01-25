extends Node2D

@onready var enemies_container = $GameplayLayer/Enemies
var Yeast = preload("res://scenes/enemies/Yeast.tscn")

func _ready():
	# Position floor at bottom of background plus 20px
	var bg_sprite = $Background/Sprite2D
	var floor_node = $Background/Floor
	if bg_sprite and bg_sprite.texture:
		var bg_height = bg_sprite.texture.get_height()
		floor_node.position.y = bg_height / 2 - 40
	
	spawn_yeasts()

func spawn_yeasts():
	# Calculate screen dimensions
	var viewport_size = get_viewport_rect().size
	var spawn_width = viewport_size.x * 0.8 # Use 80% of screen width
	var spawn_y = viewport_size.y * 1.75
	
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
