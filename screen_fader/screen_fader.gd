extends Node2D

@export var fader: ColorRect
@export var battle_texture: TextureRect

var _tween: Tween
var _battle_tween: Tween

func _ready() -> void:
	battle_texture.visible = false

func fade_from_black(duration: float = 0.5) -> void:
	if (_tween != null):
		_tween.kill()
	_tween = get_tree().create_tween()
	_tween.tween_property(fader, "color", Color(0, 0, 0, 0), duration)
	await get_tree().create_timer(duration).timeout
	
func fade_to_black(duration: float = 0.5) -> void:
	if (_tween != null):
		_tween.kill()
	_tween = get_tree().create_tween()
	_tween.tween_property(fader, "color", Color(0, 0, 0, 1), duration)
	await get_tree().create_timer(duration).timeout

func battle_transition(duration: float = 0.75) -> void:
	if (_battle_tween != null):
		_battle_tween.kill()
	battle_texture.texture = ImageTexture.create_from_image(get_viewport().get_texture().get_image())
	battle_texture.self_modulate = Color(1, 1, 1, 1)
	battle_texture.visible = true
	_battle_tween = get_tree().create_tween().set_parallel(true)
	#_battle_tween.tween_property(battle_texture, "self_modulate", Color(1, 0, 0, 1), duration)
	_battle_tween.tween_method(_set_battle_transition_progress, 0.0, 1.0, duration)
	await get_tree().create_timer(duration).timeout
	battle_texture.visible = false
	
func _set_battle_transition_progress(progress: float) -> void:
	var shader_material: ShaderMaterial = battle_texture.material as ShaderMaterial
	shader_material.set_shader_parameter("progress", progress)
