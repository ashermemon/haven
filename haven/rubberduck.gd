extends RigidBody3D

var duck_value = 1
@onready var hud = get_tree().current_scene.get_node("HUD")
var hitcount = 0
var abletohit:= true
var is_dynamite = false

var water_controller: Node
var spawner

func _ready() -> void:
	var timer_label = get_tree().current_scene.find_child("Timer", true, false)
	timer_label.timer_finished.connect(_on_timer_finished)
	
	spawner = get_tree().current_scene.get_node("Spawner")

	water_controller = get_tree().current_scene.get_node("WaterController")
	print("WATER CONTROLLER: ", water_controller)
	var water_area = get_tree().get_first_node_in_group("water")

	if water_area:
		water_area.body_entered.connect(_on_water_entered)

	var random_rotation = Vector3(0.0, randf_range(-0.5, 0.5), 0.0)
	apply_torque_impulse(random_rotation)

	var random_force = Vector3(randf_range(-5.0, 5.0), randf_range(9.5, 12.0), 0.0)
	apply_central_impulse(random_force)

func _on_timer_finished() -> void:
	spawner.stop_spawning()
	explode()

func _on_water_entered(body: Node3D) -> void:
	if body != self:
		return

	

	var impact_strength = clampf(linear_velocity.length() / 6.0, 0.35, 1.5)

	if water_controller == null:
		return

	water_controller.splash(global_position, impact_strength)
	hitcount+=1
	if randf() < ((0.9 /hitcount)*2) && hitcount >= 2 && abletohit:

		var ran_spin = Vector3(randf_range(-0.05, 0.05), randf_range(-0.05, 0.05), randf_range(-0.05, 0.05))
		apply_torque_impulse(ran_spin * 15.0)
		
		var impulse_force = Vector3(randf_range(-1, 1), randf_range(10, 16), 0.0)
		apply_central_impulse(impulse_force)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func debris() -> void:
	var particles := GPUParticles3D.new()
	particles.one_shot = true
	particles.amount = 24
	particles.lifetime = 0.5
	particles.explosiveness = 1.0
	#particles.fixed_fps = 60

	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.1
	mesh.bottom_radius = 0.0
	mesh.height = 2.0
	mesh.radial_segments = 64
	mesh.rings = 4

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color.DARK_ORANGE
	mat.emission_enabled = true
	mat.emission = Color.ORANGE_RED
	mat.emission_energy_multiplier = 2.0
	mesh.material = mat
	mat.render_priority = 100
	particles.draw_pass_1 = mesh

	var p_mat := ParticleProcessMaterial.new()
	p_mat.spread = 180.0
	p_mat.initial_velocity_min = 12.0
	p_mat.initial_velocity_max = 14.0
	p_mat.particle_flag_align_y = true
	p_mat.scale_min = 0.5
	p_mat.scale_max = 1.5

	var curve := Curve.new()
	curve.add_point(Vector2(0.0, 1.0))
	curve.add_point(Vector2(1.0, 0.0))
	var curve_tex := CurveTexture.new()
	curve_tex.curve = curve
	p_mat.scale_curve = curve_tex

	particles.process_material = p_mat

	add_child(particles)
	particles.emitting = true

func fire() -> void:
	var particles := GPUParticles3D.new()
	particles.one_shot = true
	particles.amount = 12
	particles.lifetime = .50
	particles.explosiveness = 1.0
	#particles.fixed_fps = 60

	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 8
	mesh.rings = 4

	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.render_priority = 100 
	#mat.albedo_color = Color.DARK_ORANGE
	#mat.emission_enabled = true
	#mat.emission = Color.ORANGE_RED
	#mat.emission_energy_multiplier = 2.0
	mesh.material = mat
	particles.draw_pass_1 = mesh

	var p_mat := ParticleProcessMaterial.new()
	p_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	p_mat.direction = Vector3(0, -1, 0)
	p_mat.spread = 90.0
	p_mat.initial_velocity_min = 2
	p_mat.initial_velocity_max = 4
	p_mat.gravity = Vector3(0, 5, 0)
	p_mat.scale_min = 0.5
	p_mat.scale_max = 1.5
	p_mat.color = Color("#ffb800")

	var grad := Gradient.new()
	grad.set_color(0, Color("#ffb800"))
	grad.set_color(1, Color("#ff3b00"))
	var grad_tex := GradientTexture1D.new()
	grad_tex.gradient = grad
	p_mat.color_ramp = grad_tex

	var em_curve := Curve.new()
	em_curve.min_value = 0.0
	em_curve.max_value = 2.0
	em_curve.add_point(Vector2(0.0, 2.0), 0.0, 0.0)
	em_curve.add_point(Vector2(1.0, 1.0), 0.0, 0.0)
	var em_curve_tex := CurveTexture.new()
	em_curve_tex.width = 256
	em_curve_tex.curve = em_curve
	p_mat.emission_curve = em_curve_tex

	var scale_curve := Curve.new()
	scale_curve.add_point(Vector2(0.0, 0.01), 0.0, 0.0)
	scale_curve.add_point(Vector2(0.24, 1.0), 0.0, 0.0)
	scale_curve.add_point(Vector2(1.0, 0.0), 0.0, 0.0)
	var scale_curve_tex := CurveTexture.new()
	scale_curve_tex.curve = scale_curve
	p_mat.scale_curve = scale_curve_tex



	particles.process_material = p_mat

	add_child(particles)
	particles.emitting = true


func smoke() -> void:
	var particles := GPUParticles3D.new()
	particles.one_shot = true
	particles.amount = 12
	particles.lifetime = 2
	particles.explosiveness = 1.0
	#particles.fixed_fps = 60

	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 8
	mesh.rings = 4

	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.render_priority = 100
	#mat.albedo_color = Color.DARK_ORANGE
	#mat.emission_enabled = true
	#mat.emission = Color.ORANGE_RED
	#mat.emission_energy_multiplier = 2.0
	mesh.material = mat
	particles.draw_pass_1 = mesh

	var p_mat := ParticleProcessMaterial.new()
	p_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	p_mat.direction = Vector3(0, -1, 0)
	p_mat.spread = 45
	p_mat.initial_velocity_min = 1
	p_mat.initial_velocity_max = 2
	p_mat.gravity = Vector3(0, 5, 0)
	p_mat.scale_min = 0.5
	p_mat.scale_max = 1.5
	p_mat.color = Color("49472b")


	var scale_curve := Curve.new()
	scale_curve.add_point(Vector2(0.0, 0.01), 0.0, 0.0)
	scale_curve.add_point(Vector2(0.24, 1.0), 0.0, 0.0)
	scale_curve.add_point(Vector2(1.0, 0.0), 0.0, 0.0)
	var scale_curve_tex := CurveTexture.new()
	scale_curve_tex.curve = scale_curve
	p_mat.scale_curve = scale_curve_tex

	var alpha_curve := Curve.new()
	alpha_curve.add_point(Vector2(0.0, 0.0), 0.0, 0.0)
	alpha_curve.add_point(Vector2(0.65, 0.81), 0.0, 0.0)
	alpha_curve.add_point(Vector2(1.0, 0.0), 0.0, 0.0)
	var alpha_curve_tex := CurveTexture.new()
	alpha_curve_tex.width = 256
	alpha_curve_tex.curve = alpha_curve
	p_mat.alpha_curve = alpha_curve_tex



	particles.process_material = p_mat

	add_child(particles)
	particles.emitting = true

func explode():
	if abletohit:
		abletohit = false
	else:
		return
		
	freeze = true
	
	for child in get_children():
		if child is CollisionShape3D:
			child.set_deferred("disabled", true)
			

	var model = get_node("Model")
	model.hide()

	
	
	debris()
	fire()
	smoke()
	

	await get_tree().create_timer(3).timeout
	queue_free()
	pass


func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
		
	if event.is_action_pressed("Shoot"):
		
		var ran_spin = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)).normalized()
		apply_torque_impulse(ran_spin * 15.0)
		
		var impulse_force = Vector3(randf_range(-10, 10), 0.0, -10)
		apply_central_impulse(impulse_force)
		camera.shake_camera(10.0)
		if is_dynamite:
			explode()
		if abletohit:
			abletohit = false
			hud.add_score(duck_value)
			await get_tree().create_timer(3.0).timeout
			queue_free()
		
