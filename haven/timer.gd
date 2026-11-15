extends Label3D

signal timer_finished

@export var start_time: float = 60.0
@export var normal_color: Color = Color.WHITE
@export var warning_color: Color = Color.RED
@export var duck: PackedScene
@export var ducksilver: PackedScene
@export var duckgold: PackedScene

@export var finished_color: Color = Color.AZURE
@onready var playagainlabel: RichTextLabel = get_tree().current_scene.get_node("HUD/PlayAgain")
var spawner

var time_left: float
var is_running: bool = true
var duck_instance: Node3D

func _ready() -> void:
	time_left = start_time
	modulate = normal_color
	spawner = get_tree().current_scene.get_node("Spawner")
	update_label()

func _process(delta: float) -> void:
	if duck_instance:
		duck_instance.rotate_y(2.0 * delta)

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
		var position = Vector3(0.0, -1.25, 3.0)
		if GameManager.score < 20:
			duck_instance = duck.instantiate()
		elif GameManager.score < 60:
			duck_instance = ducksilver.instantiate()
		else:
			duck_instance = duckgold.instantiate()

		duck_instance.position = position
		duck_instance.scale = Vector3(1.7, 1.7, 1.7)
		get_tree().current_scene.add_child(duck_instance)

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
