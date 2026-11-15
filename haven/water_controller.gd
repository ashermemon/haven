
extends Node3D

@export var water_mesh: MeshInstance3D
@export var splash_particles: Array[GPUParticles3D]

var water_material: ShaderMaterial

var impact_positions: Array[Vector2] = [
	Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO
]
var impact_ages: Array[float] = [-1.0, -1.0, -1.0, -1.0]
var impact_strengths: Array[float] = [0.0, 0.0, 0.0, 0.0]

var next_slot := 0
var next_particle := 0


func _ready() -> void:
	if water_mesh == null:
		push_error("Water mesh not assigned!")
		return

	var source_material: Material = water_mesh.material_override

	if source_material == null:
		source_material = water_mesh.get_active_material(0)

	if not source_material is ShaderMaterial:
		push_error("Water material must be a ShaderMaterial!")
		return

	water_material = source_material.duplicate() as ShaderMaterial
	water_mesh.material_override = water_material

	for i in range(4):
		water_material.set_shader_parameter(
			"impact_%d" % i,
			Vector4(0.0, 0.0, -1.0, 0.0)
		)


func splash(world_position: Vector3, strength: float = 1.0) -> void:
	var slot := next_slot
	next_slot = (next_slot + 1) % 4

	impact_positions[slot] = Vector2(
		world_position.x,
		world_position.z
	)

	impact_ages[slot] = 0.0
	impact_strengths[slot] = strength

	if splash_particles.is_empty():
		return

	var emitter: GPUParticles3D = null

	for i in range(splash_particles.size()):
		var index := (next_particle + i) % splash_particles.size()
		var candidate = splash_particles[index]

		if candidate and not candidate.emitting:
			emitter = candidate
			next_particle = (index + 1) % splash_particles.size()
			break

	if emitter == null:
		print("All splash emitters are busy!")
		return

	emitter.global_position = Vector3(
		world_position.x,
		water_mesh.global_position.y + 0.03,
		world_position.z
	)

	emitter.restart()
	emitter.emitting = true


func _process(delta: float) -> void:
	if water_material == null:
		return

	for i in range(4):
		if impact_ages[i] >= 0.0:
			impact_ages[i] += delta

			if impact_ages[i] > 1.8:
				impact_ages[i] = -1.0

		var data := Vector4(
			impact_positions[i].x,
			impact_positions[i].y,
			impact_ages[i],
			impact_strengths[i]
		)

		water_material.set_shader_parameter(
			"impact_%d" % i,
			data
		)
