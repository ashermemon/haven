extends RichTextLabel

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	bbcode_enabled = true
	meta_clicked.connect(_on_meta_clicked)
	
	if not GameManager.has_started_once:

		get_tree().paused = true
		GameManager.gameActive = false
		text = "[url=PlayAgain]Click to Play[/url]"
		show()
	else:
		
		get_tree().paused = false
		GameManager.gameActive = true
		GameManager.score = 0
		text = "[url=PlayAgain]Play Again[/url]"
		hide()

func _on_meta_clicked(meta: Variant) -> void:
	if str(meta) == "PlayAgain":
		if not GameManager.has_started_once:
			GameManager.has_started_once = true
			get_tree().paused = false
			GameManager.gameActive = true
			GameManager.score = 0
			text = "[url=PlayAgain]Play Again[/url]"
			hide()
		else:
			get_tree().reload_current_scene()
