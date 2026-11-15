extends CanvasLayer

@onready var score_label: RichTextLabel = $MarginContainer/ScoreLabel
@onready var playagain_label: RichTextLabel = $PlayAgain

func _ready() -> void:
	playagain_label.hide()
	var timer_label = get_tree().current_scene.find_child("Timer", true, false)
	timer_label.timer_finished.connect(_on_timer_finished)
	

func add_score(points: int) -> void:
	GameManager.score += points
	score_label.text = "Score: " + str(GameManager.score)

func _on_timer_finished() -> void:
	score_label.hide()
