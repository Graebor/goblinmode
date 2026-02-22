@tool
extends Path3D


@onready var segment_scene: PackedScene = preload("res://obstacles/tube/tube_segment.tscn")
@onready var corner_scene: PackedScene = preload("res://obstacles/tube/tube_corner.tscn")
@onready var segments: Node3D = $Segments
@onready var entry: Area3D = $EntryArea3D
@onready var exit: Area3D = $ExitArea3D

var balls_forward: Dictionary[Node3D, float] = {}
var balls_backward: Dictionary[Node3D, float] = {}
var speed: float = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	curve_changed.connect(_regenerate)
	entry.area_entered.connect(_on_entry_entered)
	exit.area_entered.connect(_on_exit_entered)
	
	var start_pos: Vector3 = curve.get_point_position(0)
	var end_pos: Vector3 = curve.get_point_position(curve.point_count - 1)
	start_pos.y = 0
	end_pos.y = 0
	curve.set_point_position(0, start_pos)
	curve.set_point_position(curve.point_count - 1, end_pos)
	_regenerate()


func _on_entry_entered(node: Node3D) -> void:
	if node.is_in_group("Ball") and not node.is_in_group("InHand") and not node.is_in_group("Sinking"):
		balls_forward[node] = curve.get_baked_length()
		node.visible = false


func _on_exit_entered(node: Node3D) -> void:
	if node.is_in_group("Ball") and not node.is_in_group("InHand") and not node.is_in_group("Sinking"):
		balls_backward[node] = curve.get_baked_length()
		node.visible = false


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	for ball: Node3D in balls_forward.keys():
		balls_forward[ball] -= speed * delta
		if balls_forward[ball] <= 0.0:
			balls_forward.erase(ball)
			_spawn(ball, exit, curve.get_point_position(curve.point_count - 1))
		
	for ball: Node3D in balls_backward.keys():
		balls_backward[ball] -= speed * delta
		if balls_backward[ball] <= 0.0:
			balls_backward.erase(ball)
			_spawn(ball, entry, curve.get_point_position(0))

func _spawn(ball: Node3D, area: Area3D, tube_position: Vector3) -> void:
	ball.visible = true
	ball.global_position.x = area.global_position.x
	ball.global_position.z = area.global_position.z
	
	var area_pos: Vector3 = area.global_position
	area_pos.y = 0
	tube_position.y = 0
	
	var direction: Vector3 = area_pos - tube_position
	var body: RigidBody3D = ball as RigidBody3D
	body.apply_impulse(direction * 5.0)


func _regenerate() -> void:
	for child in segments.get_children():
		child.queue_free()
	
	if curve.point_count < 2:
		return
	
	entry.global_position = curve.get_point_position(0)
	exit.global_position = curve.get_point_position(curve.point_count - 1)
	
	for point: int in curve.point_count - 1:
		var current_pos: Vector3 = curve.get_point_position(point)
		var next_pos: Vector3 = curve.get_point_position(point + 1)
		
		var instance: Node3D = segment_scene.instantiate()
		instance.get_child(0).height = current_pos.distance_to(next_pos)
		instance.get_child(1).height = current_pos.distance_to(next_pos) + 0.01
		#instance.rotation_degrees.y = position.angle_to(next_pos)
		instance.look_at_from_position(current_pos.lerp(next_pos, 0.5), next_pos, Vector3.RIGHT)
		segments.add_child(instance)
		
		if point == 0:
			continue
		
		var corner: Node3D = corner_scene.instantiate()
		corner.position = current_pos
		segments.add_child(corner)
		
