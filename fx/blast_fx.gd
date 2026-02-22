extends Node3D
class_name BlastFX

@export var anim: AnimationPlayer
@export var mesh: MeshInstance3D
@export var small: bool = false

func blast(color: Color) -> void:
	var mat: StandardMaterial3D = mesh.get_surface_override_material(0)
	mat.albedo_color = color
	
	anim.play("RESET")
	anim.advance(0)
	if small:
		anim.play(&"blast/smallblast")
	else:
		anim.play(&"blast/holeblast")
	anim.advance(0)
