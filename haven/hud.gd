extends CanvasLayer

@onready var score_label: RichTextLabel = $ScoreLabel

func add_score(points: int) -> void:
	GameManager.score += points
	score_label.text = "Score: " + str(GameManager.score)
