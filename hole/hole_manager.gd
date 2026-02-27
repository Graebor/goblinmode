extends Node


signal ball_sunk(player_context: PlayerContext, hole: Hole)
signal ball_sinking(player_context: PlayerContext)
signal round_finished


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ball_sunk.connect(_on_ball_sunk)


func _on_ball_sunk(_player_context: PlayerContext, _hole: Hole) -> void:
	var hole_count: int = get_tree().get_nodes_in_group("Hole").size()
	
	var balls: Array[Node] = get_tree().get_nodes_in_group("Ball")
	var remaining: int = 0
	for ball: Node in balls:
		if not ball.is_queued_for_deletion():
			remaining += 1
	
	if remaining == 0 and hole_count > 0:
		# all balls are gone but only if the course has a hole
		round_finished.emit()
		return
