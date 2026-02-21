class_name Hole
extends Node3D

@onready var area3d: Area3D = %Area3D

@export var sinking_speed: float = 0.5
@export var min_distance_to_sink: float = 0.2
var sinking_balls: Array[RigidBody3D] = []


func _physics_process(delta: float) -> void:
	for body: Node3D in area3d.get_overlapping_bodies():
		if body.is_in_group("Ball") and not body.is_in_group("InHand") and not body.is_in_group("Sinking"):
			_start_sink_ball(body)

	_sink_balls(delta)

func _start_sink_ball(ball: RigidBody3D) -> void:
	var item: Item = ball as Item
	if item.last_player == null:
		return
	
	ball.add_to_group("Sinking")
	ball.set_collision_layer_value(3, false) # Item
	ball.set_collision_layer_value(4, false) # Ball
	sinking_balls.push_back(ball)
	
	HoleManager.ball_sinking.emit(item.last_player)
	

func _sink_balls(delta: float) -> void:
	for ball: RigidBody3D in sinking_balls:
		var ball_postion_2d := Vector2(ball.global_position.x, ball.global_position.z)
		var hole_position_2d := Vector2(global_position.x, global_position.z)
		ball_postion_2d = ball_postion_2d.move_toward(hole_position_2d, sinking_speed * delta)
		if ball_postion_2d.distance_to(hole_position_2d) > min_distance_to_sink:
			ball.global_position = Vector3(\
			ball_postion_2d.x, \
			ball.global_position.y, \
			ball_postion_2d.y)
		else:
			ball.global_position = Vector3(\
			ball_postion_2d.x, \
			ball.global_position.y - (sinking_speed * 8.0 * delta), \
			ball_postion_2d.y)
		if ball_postion_2d == hole_position_2d and ball_postion_2d.y > 0.5:
			_remove_ball(ball)


func _remove_ball(ball: RigidBody3D) -> void:
	var item: Item = ball as Item
	ball.queue_free()
	sinking_balls.erase(ball)
	HoleManager.ball_sunk.emit(item.last_player)
