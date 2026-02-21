extends Node3D
class_name ScorePanel

@export var score_label: Label3D
@export var name_label: Label3D
@export var trophies: Array[Node3D]
@export var speed_curve: Curve
@export var scaler: Node3D

var _rank: int = -1
var _t: float = 0.0

func setup(rank: int, score: int, player: PlayerContext) -> void:
	_rank = rank
	score_label.text = str(score)
	if (player != null):
		name_label.text = "Player "+str(player.device_id)
	for i: int in range(trophies.size()):
		trophies[i].visible = rank == i
	scaler.scale.x = lerp(1.3, 0.95, rank / 4.0)
	
func _process(delta: float) -> void:
	if (_rank != -1):
		_t += delta
		trophies[_rank].rotation_degrees.y += speed_curve.sample(clamp(_t, 0, 2)) * delta
