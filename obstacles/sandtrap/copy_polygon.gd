extends CollisionPolygon3D

@export var poly: CSGPolygon3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	polygon = poly.polygon
