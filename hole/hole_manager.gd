extends Node


signal ball_sunk(player_context: PlayerContext)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ball_sunk.connect(_on_ball_sunk)


func _on_ball_sunk(_player_context: PlayerContext) -> void:
	var balls: Array[Node] = get_tree().get_nodes_in_group("Ball")
	if not balls or balls.size() == 0:
		#end
		pass
