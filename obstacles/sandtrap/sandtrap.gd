@tool
extends CSGPolygon3D

@export var area: Area3D
const SAND_GROUP: String = "Sand"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		global_position.y = -0.48
	
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)


func _on_body_entered(node: Node3D) -> void:
	node.add_to_group(SAND_GROUP)


func _on_body_exited(node: Node3D) -> void:
	node.remove_from_group(SAND_GROUP)
