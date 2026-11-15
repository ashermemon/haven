extends RigidBody3D

var duck_value = 5
@onready var hud = get_tree().current_scene.get_node("HUD")

var abletohit:= true

var water_controller: Node

func _ready() -> void:
	water_controller = get_tree().current_scene.get_node("WaterController")
	print("WATER CONTROLLER: ", water_controller)
	var water_area = get_tree().get_first_node_in_group("water")

	if water_area:
		water_area.body_entered.connect(_on_water_entered)

	# Keep your existing launch code below
	var random_rotation = Vector3(0.0, randf_range(-0.5, 0.5), 0.0)
	apply_torque_impulse(random_rotation)

	var random_force = Vector3(randf_range(-5.0, 5.0), randf_range(9.5, 12.0), 0.0)
	apply_central_impulse(random_force)


func _on_water_entered(body: Node3D) -> void:
	if body != self:
		return

	print("DUCK ENTERED WATER!")

	var impact_strength = clampf(linear_velocity.length() / 6.0, 0.35, 1.5)

	if water_controller == null:
		print("ERROR: WATER CONTROLLER NOT FOUND")
		return

	print("TRIGGERING SPLASH!")
	water_controller.splash(global_position, impact_strength)
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
		camera.shake_camera(10.0)
		await get_tree().create_timer(3.0).timeout
		queue_free()
