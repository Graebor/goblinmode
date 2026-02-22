extends Node3D
class_name ScoreScreen

signal finished_looking_at_scores

@export var time: float = 3.0
@export var main_label: Label3D
@export var rounds_label: Label3D
@export var spin_bg: Node3D
@export var clock_hand: Node3D
@export var clock_root: Node3D
@export var input_prompt: Node3D
@export var score_panels: Array[ScorePanel]

var _elapsed: float = 0.0
var _needs_input: bool = false

func _ready() -> void:
	input_prompt.visible = false
	
	for panel: ScorePanel in score_panels:
		panel.visible = false

	_reveal_panels()
	
	await get_tree().create_timer(time).timeout
	
	clock_root.visible = false
	
	if (_needs_input):
		input_prompt.visible = true
		while (_needs_input):
			if (Input.is_action_just_pressed("swing")):
				_needs_input = false
				input_prompt.visible = false
			else:
				await get_tree().process_frame
	
	finished_looking_at_scores.emit()

func setup(finished_level: int, total_levels: int) -> void:
	_needs_input = true
	if (finished_level >= total_levels):
		main_label.text = "FINAL SCORES"
		rounds_label.text = "after all " + str(total_levels) + " holes"
	else:
		main_label.text = "SCORES"
		rounds_label.text = "after "+str(finished_level) + "/" + str(total_levels) + " holes"

func _sort_by_score(a: PlayerContext, b: PlayerContext) -> bool:
	return (GameManager.game.get_score(a) > GameManager.game.get_score(b))

func _reveal_panels() -> void:
	var i: int = 0
	
	var players: Array[PlayerContext]
	players.append_array(PlayerManager.players)
	players.sort_custom(_sort_by_score)
	
	for context: PlayerContext in players:
		var score = GameManager.game.get_score(context)

		await get_tree().create_timer(0.13).timeout
		
		var panel: ScorePanel = score_panels[i]
		
		panel.setup(i, score, context)
		panel.visible = true
		panel.rotation_degrees.x = -180
		
		var tween: Tween = get_tree().create_tween().set_parallel(true)
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
		tween.tween_property(panel, "rotation_degrees:x", 0, 0.5)
		tween.set_trans(Tween.TRANS_QUAD)
		tween.tween_property(panel, "scale", Vector3(1.2, 0.9, 0.9), 0.2)
		tween.set_ease(Tween.EASE_IN)
		tween.set_parallel(false)
		tween.tween_property(panel, "scale", Vector3(1, 1, 1), 0.1)
		
		i += 1

func _process(delta: float) -> void:
	spin_bg.rotation_degrees.y += delta * 20
	_elapsed += delta / time
	clock_hand.rotation_degrees.z = -720.0 * _elapsed
