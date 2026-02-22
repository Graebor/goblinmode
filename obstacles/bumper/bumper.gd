@tool
extends RigidBody3D

@export var radius: float = 2.0
@export var tweener: Node3D
@export var sfx_bounce: AudioCollectionData

var _tween: Tween

@onready var scaler: Node3D = $Scaler
@onready var collider: CollisionShape3D = $CollisionShape3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_resize()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_resize()

func _resize() -> void:
	scaler.scale = Vector3.ONE * radius * 2.0
	var collision_shape := collider.shape as CylinderShape3D
	collision_shape.radius = radius


func _on_body_entered(node: Node3D) -> void:
	if not node is RigidBody3D:
		return
		
	var body: RigidBody3D = node as RigidBody3D
	
	var self_pos: Vector3 = global_position
	var node_pos: Vector3 = node.global_position
	self_pos.y = 0
	node_pos.y = 0
	
	var direction: Vector3 = node_pos - self_pos
	body.linear_velocity = (max(body.linear_velocity.length(), 4.0) * direction)
	_do_tween(clamp(body.linear_velocity.length() / 4.0, 0.0, 1.0))
	sfx_bounce.play3D(position)
	if not body is PlayerController:
		return
		
	var player: PlayerController = body as PlayerController
	player.stun(0.5)

func _do_tween(amount: float) -> void:
	if (_tween != null):
		_tween.kill()
	_tween = get_tree().create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	_tween.tween_property(tweener, "scale", Vector3.ONE * lerp(1.03, 1.2, amount), 0.05)
	_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	_tween.tween_property(tweener, "scale", Vector3.ONE, lerp(0.2, 0.4, amount))
	_tween.tween_callback(_on_tween_complete)

func _on_tween_complete() -> void:
	_tween = null
