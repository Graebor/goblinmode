extends Node
class_name Game

@export var title_scene: PackedScene
@export var player_scene: PackedScene
@export var lobby_scene: PackedScene
@export var score_screen_scene: PackedScene
@export var levels: Array[PackedScene]
@export var game_camera: Camera3D
@export var countdown: Countdown
@export var shaker: Node3D
@export var shake_angle: float = 5.0
@export var shake_freq: float = 1.0
@export var sfx_confirm_title: AudioCollectionData

@export var music_main: AudioStream
@export var music_title: AudioStream
@export var music_lobby: AudioStream
@export var music_scores: AudioStream

var _title: Node
var _scores: Dictionary[PlayerContext, int]
var _previous_scores: Dictionary[PlayerContext, int]
var _active_level_index: int = -1
var _active_level: Node
var _lobby: Lobby
var _score_screen: ScoreScreen
var _round_finished: bool
var _current_shake: float = 1.0

func get_score(player: PlayerContext) -> int:
	if (_scores.has(player)):
		return _scores[player]
	return 0

func get_previous_score(player: PlayerContext) -> int:
	if (_previous_scores.has(player)):
		return _previous_scores[player]
	return 0

func screenshake(amount: float = 1.0) -> void:
	_current_shake = max(_current_shake, amount)

func _ready() -> void:
	GameManager.game = self
	_title = title_scene.instantiate()
	add_child(_title)
	game_camera.current = false
	AudioManager.PlayMusic(music_title)
	HoleManager.round_finished.connect(_on_round_finished)

func _process(delta: float) -> void:
	if not is_instance_valid(_score_screen) and _active_level_index >= 0:
		if Input.is_action_just_pressed("level_next") and _active_level_index < levels.size() - 1:
			_on_round_finished(true)
		if Input.is_action_just_pressed("level_prev"):
			_active_level_index = max(-1, _active_level_index - 2)
			_on_round_finished(true)
	
	if (_current_shake > 0):
		_current_shake -= delta * 3
		shaker.rotation_degrees.x = sin(_current_shake * shake_freq) * shake_angle * _current_shake
	else:
		shaker.rotation_degrees.x = 0
	
	if (_title != null):
		if (Input.is_action_just_pressed("swing")):
			sfx_confirm_title.play3D(_title.position)
			_title.queue_free()
			_title = null
			ScreenFader.battle_transition()
			await get_tree().process_frame
			_move_to_lobby()

func _move_to_lobby() -> void:
	ScreenFader.fade_from_black()
	AudioManager.PlayMusic(music_lobby)
	_active_level_index = -1
	_lobby = lobby_scene.instantiate()
	add_child(_lobby)
	game_camera.current = false
	_lobby.players_confirmed.connect(_on_players_confirmed)


func _on_players_confirmed() -> void:
	if (_lobby != null):
		_lobby.queue_free()
		_lobby = null
		_scores.clear()
		_previous_scores.clear()
		_begin_level(0)


func _begin_level(index: int) -> void:
	ScreenFader.battle_transition(0.3)
	AudioManager.PlayMusic(null)
	
	if (index < levels.size()):
		print("starting level " + str(index))
		_active_level_index = index
		_clear_active_level()
		_active_level = levels[index].instantiate()
		add_child(_active_level)
		game_camera.current = true
		_round_finished = false
		
		var spawns: Array[Node] = get_tree().get_nodes_in_group("Spawn")
		var shuffled: Array[Node3D]
		for spawn: Node in spawns:
			if (spawn is Node3D):
				shuffled.insert(randi_range(0, shuffled.size()), spawn as Node3D)
		
		var i: int = 0
		for context: PlayerContext in PlayerManager.players:
			var j: int = wrap(i, 0, shuffled.size())
			PlayerManager.spawn_player(context, shuffled[j].global_position)
			i += 1

		await countdown.run()
		
		AudioManager.PlayMusic(music_main, true)
		GameManager.notify_level_started()
	else:
		print("all levels done, going to lobby")
		await ScreenFader.fade_to_black()
		_move_to_lobby()


func _on_round_finished(instant: bool) -> void:
	if (_round_finished):
		return
		
	AudioManager.PlayMusic(music_scores)
	
	_round_finished = true
	if (!instant):
		await get_tree().create_timer(2).timeout
	await ScreenFader.fade_to_black(0.2)
	
	_clear_active_level()
	
	print("adding scores together")
	_previous_scores = _scores.duplicate()
	for player: PlayerContext in PlayerManager.round_order.keys():
		var points: int = PlayerManager.players.size() - PlayerManager.round_order[player]
		if (!_scores.has(player)):
			_scores[player] = points
		else:
			_scores[player] += points

	_score_screen = score_screen_scene.instantiate()
	_score_screen.setup(_active_level_index + 1, levels.size())
	add_child(_score_screen)
	game_camera.current = false
	_score_screen.finished_looking_at_scores.connect(_on_finished_looking_at_scores)
	
	ScreenFader.fade_from_black(0.2)

	
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
