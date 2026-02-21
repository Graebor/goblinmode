extends Node


signal ball_sunk(player_context: PlayerContext)
signal ball_sinking(player_context: PlayerContext)
signal round_finished


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ball_sunk.connect(_on_ball_sunk)


func _on_ball_sunk(_player_context: PlayerContext) -> void:
	var balls: Array[Node] = get_tree().get_nodes_in_group("Ball")
	var remaining: int = 0
	for ball: Node in balls:
		if not ball.is_queued_for_deletion():
			remaining += 1
	
	if PlayerManager.round_order.keys().size() >= PlayerManager.players.size() - 1 \
	or remaining == 0:
		round_finished.emit()
		pass
