extends Node3D


var score = 0
var gameActive = true
@onready var shoot_sound: AudioStreamPlayer = get_tree().current_scene.get_node("ShotSound")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Shoot"):
		shoot_sound.play()
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
