extends RigidBody3D

@export var move_force: float = 10

func _physics_process(_delta: float) -> void:
	var direction: Vector2 = Vector2.ZERO
	if (Input.is_action_pressed("down")):
		direction.y = 1
	elif (Input.is_action_pressed("up")):
		direction.y = -1
	
	if (Input.is_action_pressed("left")):
		direction.x = -1
	elif (Input.is_action_pressed("right")):
		direction.x = 1
	
	direction = direction.normalized()
	
	apply_force(Vector3(direction.x * move_force, 0, direction.y * move_force), position)


func _on_body_entered(body: Node) -> void:
	var rb: RigidBody3D = body as RigidBody3D
	if (rb != null):
		print("hit")
		var direction: Vector3 = body.global_position - global_position
		rb.apply_impulse(direction.normalized() * 10)
