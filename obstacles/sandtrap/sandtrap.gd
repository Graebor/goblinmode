extends Node

@export var area: Area3D
const SAND_GROUP: String = "Sand"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area.area_entered.connect(_on_area_entered)
	area.area_exited.connect(_on_area_exited)


func _on_area_entered(node: Node3D) -> void:
	node.add_to_group(SAND_GROUP)


func _on_area_exited(node: Node3D) -> void:
	node.remove_from_group(SAND_GROUP)
