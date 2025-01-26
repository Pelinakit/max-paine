extends AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play("swimming")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var can_shoot = get_parent().get_parent().can_shoot
	if can_shoot:
		play("swimming")
	else:
		play("shoot")
