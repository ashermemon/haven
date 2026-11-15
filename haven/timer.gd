extends Label3D

signal timer_finished

@export var start_time: float = 10.0
@export var normal_color: Color = Color.WHITE
@export var warning_color: Color = Color.RED

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
		update_label()
		timer_finished.emit()
		return

	update_label()

func update_label() -> void:
	text = "%d" % ceil(time_left)
	
	if time_left <= 10.0:
		modulate = warning_color
	else:
		modulate = normal_color
