extends Node

signal player_joined(context: PlayerContext)

var player_scene: PackedScene = preload("res://player/player.tscn")
var personalities: Array[Personality] = [
	preload("res://player/personality1.tres"),
	preload("res://player/personality2.tres"),
	preload("res://player/personality3.tres"),
	preload("res://player/personality4.tres")
]

var players: Array[PlayerContext] = []

var round_order: Dictionary[PlayerContext, int] = {}
var round_order_index: int = 0
var players_already_done: Array[PlayerContext]

func _ready() -> void:
	HoleManager.ball_sinking.connect(_on_ball_sink)
	GameManager.level_started.connect(_on_level_started)
	
	
func _on_ball_sink(player_context: PlayerContext) -> void:
	if (!players_already_done.has(player_context)):
		players_already_done.append(player_context)
		round_order_index += 1
		round_order[player_context] = round_order_index


func _on_level_started() -> void:
	round_order_index = 0
	round_order.clear()
	players_already_done.clear()


func _is_new_player(new_context: PlayerContext) -> bool:
	for context: PlayerContext in players:
		if context.is_keyboard_player_1 and new_context.is_keyboard_player_1:
			return false
		elif context.is_keyboard_player_2 and new_context.is_keyboard_player_2:
			return false
		elif new_context.is_keyboard_player_1 == false and new_context.is_keyboard_player_2 == false:
			if new_context.device_id != -1 and new_context.device_id == context.device_id:
				return false
	return true


func add_player(player_context: PlayerContext) -> void:
	player_context.personality = personalities[wrapi(players.size(), 0, personalities.size())]
	players.push_back(player_context)
	player_joined.emit(player_context)


func spawn_player(player_context: PlayerContext) -> PlayerController:
	var player_instance: PlayerController = player_scene.instantiate()
	player_instance.player_context = player_context
	player_instance.name = "Player %s" % [players.size()]
	add_child(player_instance)
	return player_instance


func clear_player_instances() -> void:
	for child: Node in get_children():
		child.queue_free()

func clear_all_player_information() -> void:
	clear_player_instances()
	players.clear()

func is_action_pressed(action: String, player_context: PlayerContext) -> bool:
	if player_context.is_keyboard_player_1:
		return Input.is_action_pressed("p1_" + action)
	
	if player_context.is_keyboard_player_2:
		return Input.is_action_pressed("p2_" + action) 

	if Input.is_action_pressed(action):
		for event: InputEvent in InputMap.action_get_events(action):
			if event is InputEventJoypadButton:
				var joypad_event: InputEventJoypadButton = event as InputEventJoypadButton
				return Input.is_joy_button_pressed(player_context.device_id, joypad_event.button_index)
	
	return false


func is_action_just_pressed(action: String, player_context: PlayerContext) -> bool:
	if player_context.is_keyboard_player_1:
		return Input.is_action_just_pressed("p1_" + action)
	
	if player_context.is_keyboard_player_2:
		return Input.is_action_just_pressed("p2_" + action) 
	
	if Input.is_action_just_pressed(action):
		for event: InputEvent in InputMap.action_get_events(action):
			if event is InputEventJoypadButton:
				var joypad_event: InputEventJoypadButton = event as InputEventJoypadButton
				return Input.is_joy_button_pressed(player_context.device_id, joypad_event.button_index)
	
	return false
		


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("p1_swing"):
		var player_context: PlayerContext = PlayerContext.new()
		player_context.is_keyboard_player_1 = true
		if _is_new_player(player_context):
			add_player(player_context)
		return
	
	if Input.is_action_just_pressed("p2_swing"):
		var player_context: PlayerContext = PlayerContext.new()
		player_context.is_keyboard_player_2 = true
		if _is_new_player(player_context):
			add_player(player_context)
		return
	
	
	if Input.is_action_just_pressed("swing"):
		for event: InputEvent in InputMap.action_get_events("swing"):
			if event is InputEventJoypadButton:
				var joypad_event: InputEventJoypadButton = event as InputEventJoypadButton
				if Input.is_joy_button_pressed(0, joypad_event.button_index):
					var player_context: PlayerContext = PlayerContext.new()
					player_context.device_id = 0
					if _is_new_player(player_context):
						add_player(player_context)
					return
				elif Input.is_joy_button_pressed(1, joypad_event.button_index):
					var player_context: PlayerContext = PlayerContext.new()
					player_context.device_id = 1
					if _is_new_player(player_context):
						add_player(player_context)
					return
				elif Input.is_joy_button_pressed(2, joypad_event.button_index):
					var player_context: PlayerContext = PlayerContext.new()
					player_context.device_id = 2
					if _is_new_player(player_context):
						add_player(player_context)
					return
				elif Input.is_joy_button_pressed(3, joypad_event.button_index):
					var player_context: PlayerContext = PlayerContext.new()
					player_context.device_id = 3
					if _is_new_player(player_context):
						add_player(player_context)
					return
