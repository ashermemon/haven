extends RigidBody3D

var duck_value = 5
@onready var camera = $Camera3D
@onready var hud = get_tree().current_scene.get_node("HUD")

var abletohit:= true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var random_rotation = Vector3(randf_range(-0.5, 0.5), randf_range(-1.5, 1.5), 0.0)
	rotation = random_rotation
	var random_force = Vector3(randf_range(-5.0, 5.0), randf_range(10.0, 14.0), 0.0)
	apply_central_impulse(random_force)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
		
	if event.is_action_pressed("Shoot") and abletohit:
		abletohit = false
		var ran_spin = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)).normalized()
		apply_torque_impulse(ran_spin * 15.0)
		
		var impulse_force = Vector3(randf_range(-10, 10), 0.0, -10)
		apply_central_impulse(impulse_force)
		
		hud.add_score(duck_value)
		print("shot ducky" + str(GameManager.score))
		camera.shake_camera(10.0)
		await get_tree().create_timer(3.0).timeout
		queue_free()
