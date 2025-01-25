extends Area2D

@export var speed = 500

func _physics_process(delta):
	position.y += speed * delta
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage()
	queue_free()

func _on_area_entered(area: Area2D):
	var parent = area.get_parent()
	if parent and parent.has_method("take_damage"):
		parent.take_damage()
	queue_free()
