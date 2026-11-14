extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var random_force = Vector3(randf_range(-5.0, 5.0), randf_range(8.0, 16.0), 0.0)
	apply_central_impulse(random_force)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
