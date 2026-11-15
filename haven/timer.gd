extends Label3D

signal timer_finished

@export var start_time: float = 60.0
var time_left: float
var is_running: bool = true

func _ready() -> void:
	time_left = start_time
	update_label()

func _process(delta: float) -> void:
	if not is_running:
		return

	time_left -= delta

	if time_left <= 0.0:
		time_left = 0.0
		is_running = false
		update_label()
		timer_finished.emit()
		return

	update_label()

func update_label() -> void:
	text = "%d" % ceil(time_left)
	
