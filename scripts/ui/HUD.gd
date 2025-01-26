extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var score_rate_label = $ScoreRateLabel

func _ready():
	update_display()

func _process(_delta):
	update_display()

func update_display():
	score_label.text = "Score: %d/%d" % [Global.player_score, Global.WIN_SCORE]
	score_rate_label.text = "Points/sec: %d" % Global.score_per_second
