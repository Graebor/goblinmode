extends Node
class_name Game

@export var player_scene: PackedScene
@export var lobby_scene: PackedScene
@export var score_screen_scene: PackedScene
@export var levels: Array[PackedScene]

var _scores: Dictionary[PlayerContext, int]
var _active_level_index: int = -1
var _active_level: Node
var _lobby: Lobby
var _score_screen: ScoreScreen

func get_score(player: PlayerContext) -> int:
	if (_scores.has(player)):
		return _scores[player]
	return 0

func _ready() -> void:
	GameManager.game = self
	_move_to_lobby()
	HoleManager.round_finished.connect(_on_round_finished)


func _move_to_lobby() -> void:
	_active_level_index = -1
	_lobby = lobby_scene.instantiate()
	add_child(_lobby)
	_lobby.players_confirmed.connect(_on_players_confirmed)


func _on_players_confirmed() -> void:
	if (_lobby != null):
		_lobby.queue_free()
		_lobby = null
		_scores.clear()
		_begin_level(0)


func _begin_level(index: int) -> void:
	if (index < levels.size()):
		print("starting level " + str(index))
		_active_level_index = index
		_clear_active_level()
		_active_level = levels[index].instantiate()
		add_child(_active_level)
		
		for context: PlayerContext in PlayerManager.players:
			PlayerManager.spawn_player(context)
		
		GameManager.notify_level_started()
	else:
		print("all levels done, going to lobby")
		_move_to_lobby()


func _on_round_finished() -> void:
	_clear_active_level()
	
	print("adding scores together")
	for player: PlayerContext in PlayerManager.round_order.keys():
		var points: int = PlayerManager.players.size() - PlayerManager.round_order[player]
		if (!_scores.has(player)):
			_scores[player] = points
		else:
			_scores[player] += points
	
	_score_screen = score_screen_scene.instantiate()
	_score_screen.setup(_active_level_index + 1, levels.size())
	add_child(_score_screen)
	_score_screen.finished_looking_at_scores.connect(_on_finished_looking_at_scores)

	
func _on_finished_looking_at_scores() -> void:
	if (_score_screen != null):
		_score_screen.queue_free()
		_score_screen = null
	_begin_level(_active_level_index + 1)


func _clear_active_level() -> void:
	PlayerManager.clear_player_instances()
	ItemManager.clear()
	if (_active_level != null):
		_active_level.queue_free()
		_active_level = null
