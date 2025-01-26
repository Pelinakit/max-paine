extends CanvasLayer

# Reference the pause toggle key from the Input Map
@export var pause_action: String = "ui_pause"

func _ready():
	# Ensure the pause menu is hidden when the game starts
	hide()

# Toggle the pause menu visibility and game pause state
func toggle_pause():
	if is_visible():
		hide()  # Hide the pause menu
		get_tree().paused = false  # Unpause the game
	else:
		show()  # Show the pause menu
		get_tree().paused = true  # Pause the game

func _process(delta):
	# Check if the pause key (Esc) is pressed
	if Input.is_action_just_pressed(pause_action):
		toggle_pause()

# Button: Resume
func _on_resume_pressed():
	toggle_pause()

# Button: Main Menu
func _on_main_menu_pressed():
	get_tree().paused = false  # Unpause before switching scenes
	get_tree().change_scene("res://scenes/MainMenu.tscn")  # Update with your main menu scene path

# Button: Exit
func _on_exit_pressed():
	pass


func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
