extends Control

func _ready():
	# Create a timer for 2 seconds
	var timer = get_tree().create_timer(3.0)
	timer.timeout.connect(func():
		get_tree().paused = false
		Global.reset_game()
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	)
