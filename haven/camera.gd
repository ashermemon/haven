extends Camera3D

@export var crosshair: Node3D
@export var distance: float = 1.0

func _process(_delta: float) -> void:
	var mouse := get_viewport().get_mouse_position()
	crosshair.global_position = project_position(mouse, distance)

		
func shake_camera(intensity:float):
	pass #implement later
