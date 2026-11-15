extends Label3D

signal timer_finished

@export var start_time: float = 60.0
@export var normal_color: Color = Color.WHITE
@export var warning_color: Color = Color.RED
@export var finished_color: Color = Color.AZURE
@onready var playagainlabel: RichTextLabel = get_tree().current_scene.get_node("HUD/PlayAgain")


var time_left: float
var is_running: bool = true

func _ready() -> void:
	time_left = start_time
	modulate = normal_color
	update_label()

func _process(delta: float) -> void:
	if not is_running:
		return

	time_left -= delta

	if time_left <= 0.0:
		time_left = 0.0
		is_running = false
		GameManager.gameActive = false
		update_label()
		timer_finished.emit()
		await get_tree().create_timer(2.0).timeout
		text = "Score: " + str(GameManager.score)
		playagainlabel.show()
		font_size = 1300
		modulate = finished_color
		
		return

	update_label()

func update_label() -> void:
	text = "%d" % ceil(time_left)
	
	if time_left <= 10.0:
		modulate = warning_color
	else:
		modulate = normal_color
