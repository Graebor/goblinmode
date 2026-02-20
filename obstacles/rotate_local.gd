extends AnimatableBody3D

@export var axis: Vector3
@export var force: float
	
func _process(delta: float) -> void:
	rotation += axis * force * delta
