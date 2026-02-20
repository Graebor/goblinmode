extends Node3D
class_name PowerMeter

@export var move_speed: float = 1.0
@export var color_sequence: Gradient
@export var curve: Curve

@export_subgroup("References")
@export var segment_scene: PackedScene
@export var space_per_segment: float = 2.3
@export var segment_container: Node
@export var back_scaler: Node3D
@export var arrow_mover: Node3D

var _range_of_motion: float
var _time_for_full: float
var _time: float
var _current_segments: int
var _previous_tick: int = -1
var _waiting: bool = false

func _process(delta: float) -> void:
	if (!_waiting):
		return
	
	_time += delta
	arrow_mover.position.y = -_range_of_motion - (space_per_segment / 2.0) + _get_normalized() * (_range_of_motion * 2 + space_per_segment)
	var tick: int = _get_selected_segment()
	if (tick != _previous_tick):
		
		if (_previous_tick != -1):
			var tween1: Tween = get_tree().create_tween().set_trans(Tween.TRANS_QUAD)
			tween1.set_ease(Tween.EASE_IN)
			tween1.tween_property(segment_container.get_child(_previous_tick), "position:z", 0, 0.05)
			tween1.set_parallel(true)
			tween1.tween_property(segment_container.get_child(_previous_tick), "scale", Vector3(1, 1, 1), 0.05)
			
		_previous_tick = tick
		
		var tween2: Tween = get_tree().create_tween().set_trans(Tween.TRANS_QUAD)
		tween2.set_ease(Tween.EASE_OUT)
		tween2.tween_property(segment_container.get_child(tick), "position:z", 0.7, 0.1)
		tween2.set_parallel(true)
		tween2.tween_property(segment_container.get_child(tick), "scale", Vector3(1.3, 1.0, 1.3), 0.1)
		tween2.set_parallel(false)


func begin(segments: int) -> void:
	_clear()
	visible = true
	_waiting = true
	arrow_mover.visible = true
	_previous_tick = -1
	_current_segments = segments
	back_scaler.scale.y = segments / 3.2
	_time_for_full = segments / move_speed
	_time = 0
	_range_of_motion = float(segments - 1) * space_per_segment / 2.0
	for i: int in range(segments):
		var seg: MeshInstance3D = segment_scene.instantiate()
		var mat: StandardMaterial3D = seg.get_surface_override_material(0).duplicate()
		mat.albedo_color = color_sequence.sample(float(i) / float(segments - 1))
		seg.set_surface_override_material(0, mat)
		seg.position.y = -_range_of_motion + i * space_per_segment
		segment_container.add_child(seg)

func lock_in() -> int:
	_waiting = false
	arrow_mover.visible = false
	
	var result: int = _get_selected_segment()
	var tween: Tween = get_tree().create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(segment_container.get_child(result), "position:z", 1, 0.1)
	tween.tween_property(segment_container.get_child(result), "scale", Vector3(2, 1.0, 1.0), 0.1)
	tween.set_parallel(false)
	tween.tween_callback(_on_tween_complete)
	
	return result

func _on_tween_complete() -> void:
	visible = false

func _get_normalized() -> float:
	var t: float = wrapf(_time, 0.0, _time_for_full * 2.0)
	if (t > _time_for_full):
		t = _time_for_full * 2.0 - t
	return curve.sample(t / _time_for_full)

func _get_selected_segment() -> int:
	var nrm: float = _get_normalized()
	return roundi(nrm * (_current_segments - 1))

func _clear() -> void:
	for child: Node in segment_container.get_children():
		child.queue_free()
