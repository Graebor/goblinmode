extends AnimationPlayer

func _ready() -> void:
	HoleManager.ball_sunk.connect(_on_ball_sunk)
	
func _on_ball_sunk(_player_context: PlayerContext) -> void:
	play("RESET")
	advance(0)
	play("blast/holeblast")
	advance(0)
