extends AnimationPlayer

@export var mesh: MeshInstance3D
@export var parent_hole: Hole

func _ready() -> void:
	HoleManager.ball_sunk.connect(_on_ball_sunk)
	
func _on_ball_sunk(_player_context: PlayerContext, hole: Hole) -> void:
	if (parent_hole != hole):
		return
		
	var mat: StandardMaterial3D = mesh.get_surface_override_material(0)
	mat.albedo_color = _player_context.personality.color
	
	play("RESET")
	advance(0)
	play("blast/holeblast")
	advance(0)
