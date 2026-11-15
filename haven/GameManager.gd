extends Node

var gameActive: bool = false
var score: int = 0
var has_started_once: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if not gameActive:
		return
		
	if event.is_action_pressed("Shoot"):
		var shoot_sound = get_tree().current_scene.get_node_or_null("ShotSound")
		if shoot_sound:
			shoot_sound.play()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
