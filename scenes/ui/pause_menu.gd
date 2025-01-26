extends CanvasLayer

# Reference the pause toggle key from the Input Map
@export var pause_action: String = "ui_pause"

func _ready():
	# Ensure the pause menu is hidden when the game starts
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS # Ensure pause menu can process while game is paused

# Toggle the pause menu visibility and game pause state
func toggle_pause():
	if is_visible():
		hide() # Hide the pause menu
		get_tree().paused = false # Unpause the game
	else:
		show() # Show the pause menu
		get_tree().paused = true # Pause the game

func _process(_delta):
	# Check if the pause key (Esc) is pressed
	if Input.is_action_just_pressed(pause_action):
		print("Pause key pressed")
		toggle_pause()

# Button: Resume
func _on_resume_pressed():
	print("Resume button pressed")
	toggle_pause()

func _on_quit_pressed():
	print("Quit button pressed")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
