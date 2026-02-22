extends Node3D
class_name ScorePanel

@export var score_label: Label3D
@export var score_add_label: Label3D
@export var name_label: Label3D
@export var trophies: Array[Node3D]
@export var speed_curve: Curve
@export var scaler: Node3D
@export var sfx_score_tick: AudioCollectionData

var _rank: int = -1
var _t: float = 0.0

func setup(rank: int, score: int, add: int, player: PlayerContext) -> void:
	var steps: int = add
	var vscore: int = score - add
	
	_rank = rank
	score_label.text = str(vscore)
	score_add_label.text = "+" + str(add)
	if (player != null):
		name_label.text = player.personality.title
		name_label.modulate = player.personality.color
		score_label.modulate = player.personality.color
	for i: int in range(trophies.size()):
		trophies[i].visible = rank == i
	scaler.scale.x = lerp(1.3, 0.95, rank / 4.0)
	
	await get_tree().create_timer(2.0).timeout
	
	while (steps > 0):
		steps -= 1
		vscore += 1
		score_label.text = str(vscore)
		score_add_label.text = "+" + str(steps)
		sfx_score_tick.play3D(position)
		
		var t1: Tween = get_tree().create_tween().set_trans(Tween.TRANS_QUAD)
		t1.set_ease(Tween.EASE_OUT)
		t1.tween_property(score_add_label, "scale", Vector3(0.7, 1.2, 1), 0.07)
		t1.set_ease(Tween.EASE_IN)
		t1.tween_property(score_add_label, "scale", Vector3.ONE, 0.12)
		
		var t2: Tween = get_tree().create_tween().set_trans(Tween.TRANS_QUAD)
		t2.set_ease(Tween.EASE_OUT)
		t2.tween_property(score_label, "scale", Vector3(1.0, 1.5, 1.0), 0.15)
		t2.set_ease(Tween.EASE_IN)
		t2.tween_property(score_label, "scale", Vector3.ONE, 0.15)
		
		await get_tree().create_timer(0.31).timeout
	
	score_add_label.visible = false
	
func _process(delta: float) -> void:
	if (_rank != -1):
		_t += delta
		trophies[_rank].rotation_degrees.y += speed_curve.sample(clamp(_t, 0, 2)) * delta
