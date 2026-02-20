extends Node3D

func _process(_delta: float) -> void:
	if (CameraManager.main_camera != null):
		get_parent_node_3d().look_at(CameraManager.main_camera.global_position)
