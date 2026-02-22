@tool
extends CSGPolygon3D
var time: float = 0.0
var time2: float = 0.0
var speed: float = 0.1

@export var area: Area3D

var _blast_fx: PackedScene = preload("res://fx/blast_fx.tscn")


func _ready() -> void:
	area.body_entered.connect(_on_body_entered)

	if Engine.is_editor_hint():
		global_position.y = -0.48


func _process(delta: float) -> void:
	time += delta
	time2 += delta * 0.3
	material.uv1_offset.x = Vector2.DOWN.x * time * speed
	material.uv1_offset.y = Vector2.DOWN.y * time * speed
	material.uv2_offset.x = Vector2.DOWN.x * time2 * speed
	material.uv2_offset.y = Vector2.DOWN.y * time2 * speed


func _on_body_entered(node: Node3D) -> void:
	if not node.is_in_group("Item") and not node.is_in_group("Player"):
		return
		
	if node.is_in_group("InHand"):
		return
	
	node.queue_free()
	
	var blast: BlastFX = _blast_fx.instantiate()
	blast.global_position = node.global_position
	add_sibling(blast)
	blast.blast(Color(1.0, 0.392, 0.04, 1.0))
	
	var players: Array[Node] = get_tree().get_nodes_in_group("Player")
	var remaining: int = 0
	for player: Node in players:
		if not player.is_queued_for_deletion():
			remaining += 1
	
	if node is PlayerController:
		var player_controller: PlayerController = node as PlayerController
		PlayerManager.on_player_removed(player_controller.player_context, remaining)
	
	if remaining <= 1:
		HoleManager.round_finished.emit()
		
