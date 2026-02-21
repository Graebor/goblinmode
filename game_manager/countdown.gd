extends Label3D
class_name Countdown

@export var sfx_count: Array[AudioCollectionData]
@export var sfx_go: AudioCollectionData

func run() -> void:
	visible = true
	
	for i: int in range(3):
		text = str(3 - i)
		scale = Vector3.ZERO
		sfx_count[i].play3D(position)
		var tween: Tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
		tween.tween_property(self, "scale", Vector3.ONE, 0.9)
		await get_tree().create_timer(1.0).timeout
	
	text = "GO!"
	scale = Vector3.ZERO
	var tween2: Tween = get_tree().create_tween()
	tween2.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	tween2.tween_property(self, "scale", Vector3.ONE, 0.4)
	tween2.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
	tween2.tween_property(self, "scale", Vector3.ZERO, 0.4)
	tween2.tween_callback(_on_tween_complete)

func _on_tween_complete() -> void:
	visible = false
