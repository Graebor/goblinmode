extends Node

@export var musicPlayer1: AudioStreamPlayer
@export var musicPlayer2: AudioStreamPlayer

var streams: Array[AudioStreamPlayer] = []
var streams2D: Array[AudioStreamPlayer2D] = []
var streams3D: Array[AudioStreamPlayer3D] = []
var muteMusic: bool = false
var muteSFX: bool = false
var muteMusicRequests: Array[Node] = []
var muteSFXRequests: Array[Node] = []

var active_music_player: AudioStreamPlayer
var inactive_music_player: AudioStreamPlayer

var fade: Tween
var _current_music: AudioStream

func PlayMusic(stream: AudioStream, instant: bool = false) -> void:
	if (_current_music == stream):
		return
	_current_music = stream
	
	if (active_music_player == null):
		musicPlayer1.stream = stream
		musicPlayer1.play()
		active_music_player = musicPlayer1
		inactive_music_player = musicPlayer2
		active_music_player.volume_db = -80
		if (fade != null):
			fade.kill()
		
		if (instant):
			active_music_player.volume_db = 0
		else:
			fade = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
			fade.tween_property(active_music_player, "volume_db", 0, 1)
	else:
		if (active_music_player.stream != stream):
			var old_active: AudioStreamPlayer = active_music_player
			active_music_player = inactive_music_player
			inactive_music_player = old_active
			
			active_music_player.volume_db = -80
			if (fade != null):
				fade.kill()
			
			if (instant):
				inactive_music_player.volume_db = -80
				active_music_player.volume_db = 0
			else:
				fade = get_tree().create_tween().set_parallel().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
				fade.tween_property(inactive_music_player, "volume_db", -80, 1)
				fade.set_ease(Tween.EASE_OUT)
				fade.tween_property(active_music_player, "volume_db", 0, 1)
			
			active_music_player.stream = stream
			
			if (instant):
				active_music_player.play(0)
			else:
				active_music_player.play()
		
func SetMusicPitch(pitch: float) -> void:
	musicPlayer1.pitch_scale = pitch
	musicPlayer2.pitch_scale = pitch


func PlaySound(stream: AudioStream, volume: float = 1.0, pitch: float = 1.0):
	if (stream != null):
		var s: AudioStreamPlayer = _GetAvailableAudioStreamPlayer()
		s.stream = stream
		s.volume_linear = volume
		s.pitch_scale = pitch
		s.play()

func PlaySound2D(stream: AudioStream, position: Vector2, volume: float = 1.0, pitch: float = 1.0) -> void:
	if (stream != null):
		var s: AudioStreamPlayer2D = _GetAvailableAudioStreamPlayer2D()
		s.stream = stream
		s.position = position
		s.volume_linear = volume
		s.pitch_scale = pitch
		s.play()

func PlaySound3D(stream: AudioStream, position: Vector3, volume: float = 1.0, pitch: float = 1.0) -> void:
	if (stream != null):
		var s: AudioStreamPlayer3D = _GetAvailableAudioStreamPlayer3D()
		s.stream = stream
		s.position = position
		s.volume_linear = volume
		s.pitch_scale = pitch
		s.play()


func _GetAvailableAudioStreamPlayer() -> AudioStreamPlayer:
	for i: AudioStreamPlayer in streams:
		if (!i.playing):
			return i
	var s: AudioStreamPlayer = AudioStreamPlayer.new()
	s.name = "PooledAudioStreamPlayer"
	s.bus = &"SFX"
	add_child(s)	
	streams.append(s)
	return s

func _GetAvailableAudioStreamPlayer2D() -> AudioStreamPlayer2D:
	for i: AudioStreamPlayer2D in streams2D:
		if (!i.playing):
			return i
	var s: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	s.name = "PooledAudioStreamPlayer2D"
	s.bus = &"SFX"
	add_child(s)	
	streams2D.append(s)
	return s
	
func _GetAvailableAudioStreamPlayer3D() -> AudioStreamPlayer3D:
	for i: AudioStreamPlayer3D in streams3D:
		if (!i.playing):
			return i
	var s: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	s.name = "PooledAudioStreamPlayer3D"
	s.bus = &"SFX"
	s.unit_size = 1000
	add_child(s)
	streams3D.append(s)
	return s


func AddMuteMusicRequest(requester: Node) -> void:
	if (!muteMusicRequests.has(requester)):
		muteMusicRequests.append(requester)
		_RefreshMuteMusicState()
		
func RemoveMuteMusicRequest(requester: Node) -> void:
	var index: int = muteMusicRequests.find(requester)
	if (index >= 0):
		muteMusicRequests.remove_at(index)
		_RefreshMuteMusicState()
	
func _RefreshMuteMusicState() -> void:
	muteMusic = muteMusicRequests.size() > 0
	AudioServer.set_bus_mute(2, muteMusic) #Music bus


func AddMuteSFXRequest(requester: Node) -> void:
	if (!muteSFXRequests.has(requester)):
		muteSFXRequests.append(requester)
		_RefreshMuteSFXState()
		
func RemoveMuteSFXRequest(requester: Node) -> void:
	var index: int = muteSFXRequests.find(requester)
	if (index >= 0):
		muteSFXRequests.remove_at(index)
		_RefreshMuteSFXState()
	
func _RefreshMuteSFXState() -> void:
	muteSFX = muteSFXRequests.size() > 0
	AudioServer.set_bus_mute(1, muteSFX) #SFX bus
