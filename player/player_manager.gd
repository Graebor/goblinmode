extends Node

var players: Array[PlayerContext] = []

var round_order: Dictionary[PlayerContext, int] = {}
var round_order_index: int = 0

func _ready() -> void:
	HoleManager.ball_sunk.connect(_on_ball_sunk)
	
	
func _on_ball_sunk(player_context: PlayerContext) -> void:
	round_order_index += 1
	round_order[player_context] = round_order_index
	
	
func _on_new_round() -> void:
	round_order_index = 0
	for player_context in round_order.keys():
		round_order[player_context] = -1
