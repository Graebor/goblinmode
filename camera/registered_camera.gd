extends Camera3D

func _ready() -> void:
	CameraManager.main_camera = self
