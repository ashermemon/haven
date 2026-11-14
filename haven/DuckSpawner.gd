extends Node3D



var time_since_spawn := 0.0
var spawn_position:Vector3

@export var duck_scene:PackedScene
@export var duck_freq := 1.0 # per sec
@export var duck_accel := 0.1 #per sec
@export var max_freq := 20.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	duck_freq = min(duck_freq + (duck_accel * delta), max_freq)
	var spawn_interval := 1.0 / duck_freq
	time_since_spawn += delta
	if time_since_spawn >= spawn_interval:
		time_since_spawn -= spawn_interval
		spawn_duck()
	



func spawn_duck() -> void:
	if duck_scene:
		var duck_instance = duck_scene.instantiate()
		add_child(duck_instance)
