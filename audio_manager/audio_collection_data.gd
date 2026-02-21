@tool
extends Resource
class_name AudioCollectionData

enum OverlapMode { AllowOverlap = 0, DurationBased = 1, FrameBased = 2 }

@export var clips: Array[AudioStream]
@export_range(0.0, 1.0) var chance_of_playing = 1.0
@export var overlap_mode: OverlapMode = OverlapMode.AllowOverlap
@export var min_pitch: float = 1.0
@export var max_pitch: float = 1.0
@export var min_volume: float = 1.0
@export var max_volume: float = 1.0
@export var frame_spacing: int = 1 ##Only used if overlap mode is set to FrameBased

@export_tool_button("Preview", "Callable") var t = _test_play

var _next_allowed_play: float = 0.0
var _last_played_frame: int = -1

func get_next_clip() -> AudioStream:
	return clips[randi_range(0, clips.size() - 1)]
	
func play() -> void:
	if (_ready_to_play() and randf() <= chance_of_playing):
		var clip: AudioStream = get_next_clip()
		var pitch: float = randf_range(min_pitch, max_pitch)
		AudioManager.PlaySound(clip, randf_range(min_volume, max_volume), pitch)
		_next_allowed_play = (Time.get_ticks_msec() / 1000.0) + (clip.get_length() / pitch)
		_last_played_frame = Engine.get_frames_drawn()
	
func play2D(position: Vector2) -> void:
	if (_ready_to_play() and randf() <= chance_of_playing):
		var clip: AudioStream = get_next_clip()
		var pitch: float = randf_range(min_pitch, max_pitch)
		AudioManager.PlaySound2D(clip, position, randf_range(min_volume, max_volume), pitch)
		_next_allowed_play = (Time.get_ticks_msec() / 1000.0) + (clip.get_length() / pitch)
		_last_played_frame = Engine.get_frames_drawn()
	
func play3D(position: Vector3) -> void:
	if (_ready_to_play() and randf() <= chance_of_playing):
		var clip: AudioStream = get_next_clip()
		var pitch: float = randf_range(min_pitch, max_pitch)
		AudioManager.PlaySound3D(clip, position, randf_range(min_volume, max_volume), pitch)
		_next_allowed_play = (Time.get_ticks_msec() / 1000.0) + (clip.get_length() / pitch)
		_last_played_frame = Engine.get_frames_drawn()

func _ready_to_play() -> bool:
	if (clips.size() == 0):
		return false
	if (overlap_mode == OverlapMode.AllowOverlap):
		return true
	elif (overlap_mode == OverlapMode.DurationBased):
		return (Time.get_ticks_msec() / 1000.0) >= _next_allowed_play
	elif (overlap_mode == OverlapMode.FrameBased):
		return Engine.get_frames_drawn() >= _last_played_frame + frame_spacing
	else:
		return true

#Editor functionality
var _editor_player: AudioStreamPlayer

func _test_play() -> void:
	if (_editor_player != null):
		_editor_player.free()
		_editor_player = null
		
	_editor_player = AudioStreamPlayer.new()
	_editor_player.stream = get_next_clip()
	_editor_player.volume_linear = randf_range(min_volume, max_volume)
	_editor_player.pitch_scale = randf_range(min_pitch, max_pitch)
	
	Engine.get_main_loop().root.add_child(_editor_player)
	_editor_player.play()
	
	await _editor_player.finished
	if (_editor_player != null):
		_editor_player.queue_free()
