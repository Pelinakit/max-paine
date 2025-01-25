extends CharacterBody2D

@export var growth_per_feed = 0.1
@export var max_size = 2.0
var current_size = 1.0

func _ready():
	update_size()
	$Area2D.area_entered.connect(_on_area_entered)

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
