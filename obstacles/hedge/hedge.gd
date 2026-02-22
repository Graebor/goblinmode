@tool
extends CSGPolygon3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		global_position.y = -0.25
