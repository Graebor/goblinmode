@tool
extends CSGPolygon3D

enum SnapMode {
	None,
	Meter,
	Half
}

@export var snap_mode: SnapMode = SnapMode.None
var prev_polygon: PackedVector2Array
var prev_position: Vector3
var debounce_timer: SceneTreeTimer
var debounce_time: float = 0.125

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Engine.is_editor_hint():
		return
	
	global_position.y = 0.5
	prev_polygon = polygon.duplicate()
	prev_position = global_position


func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		return
	
	rotation_degrees.x = -90
	
	if polygon != prev_polygon:
		_snap()
	
	prev_polygon = polygon.duplicate()
	
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if global_position != prev_position:
			if is_instance_valid(debounce_timer) && debounce_timer.time_left > 0:
				debounce_timer.time_left = debounce_time
			else:
				debounce_timer = get_tree().create_timer(debounce_time)
				debounce_timer.timeout.connect(_snap)
		prev_position = global_position


func _snap() -> void:
	match(snap_mode):
		SnapMode.None:
			return
		SnapMode.Meter:
			global_position = Vector3(roundf(global_position.x), global_position.y, roundf(global_position.z))
			for index: int in polygon.size():
				polygon[index] = Vector2(roundf(polygon[index].x), roundf(polygon[index].y))
			prev_polygon = polygon
			_force_gizmo_refresh()
		SnapMode.Half:
			global_position = Vector3(roundf(global_position.x * 2.0) / 2.0, global_position.y, roundf(global_position.z * 2.0) / 2.0)
			for index: int in polygon.size():
				polygon[index] = Vector2(roundf(polygon[index].x * 2.0) / 2.0, roundf(polygon[index].y * 2.0)/ 2.0)
			prev_polygon = polygon
			_force_gizmo_refresh()


func _force_gizmo_refresh():
	if Engine.is_editor_hint():
		var editor_selection = EditorInterface.get_selection()
		if editor_selection.get_selected_nodes().has(self):
			editor_selection.remove_node(self)
			editor_selection.add_node(self)
