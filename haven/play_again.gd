extends RichTextLabel

func _ready() -> void:
	bbcode_enabled = true
	text = "[url=PlayAgain]Play Again[/url]"
	meta_clicked.connect(_on_meta_clicked)

func _on_meta_clicked(meta: Variant) -> void:
	print("Clicked meta: ", meta) 
	if str(meta) == "PlayAgain":
		get_tree().paused = false
		GameManager.gameActive = true
		GameManager.score = 0
		get_tree().reload_current_scene()
		
