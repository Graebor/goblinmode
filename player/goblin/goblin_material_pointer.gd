extends Node3D
class_name GoblinMaterialPointer

@export var overrides: Array[MeshInstance3D]
@export var indices: Array[int]

func set_override(material: Material) -> void:
	var i: int = 0
	for mesh: MeshInstance3D in overrides:
		mesh.set_surface_override_material(indices[i], material)
		i += 1
