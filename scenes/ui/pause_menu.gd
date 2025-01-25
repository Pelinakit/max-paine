extends CanvasLayer

@export var background_texture : Texture2D

func toggle_pause():
	if is_visible():
		hide()
		get_tree().paused = false
	else:
		show()
		get_tree().paused = true
		
func _on_resume_pressed():
	toggle_pause()
	
func _on_exit_pressed():
	get_tree().quit()
