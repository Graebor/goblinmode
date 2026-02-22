extends CSGPolygon3D

enum Direction {
	North = 0,
	NorthEast = 1,
	East = 2,
	SouthEast = 3,
	South = 4,
	SouthWest = 5,
	West = 6,
	NorthWest = 7
}

@export var area: Area3D
@export var direction: Direction = Direction.North
@export var power: float = 2.0

var direction_vectors: Array[Vector2] = [
	Vector2(0, 1),
	Vector2(-1, 1),
	Vector2(-1, 0),
	Vector2(-1, -1),
	Vector2(0, -1),
	Vector2(1, -1),
	Vector2(1, 0),
	Vector2(1, 1)
]

@export var direction_textures: Array[Texture2D] = []

var time = 0.0
var speed = 0.1

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	time += delta
	material.uv1_offset.x = direction_vectors[direction].x * time * speed
	material.uv1_offset.y = direction_vectors[direction].y * time * speed
	material.albedo_texture = direction_textures[direction]
	

# Called when the node enters the scene tree for the first time.
func _physics_process(_delta: float) -> void:
	var nodes: Array[Node3D] = area.get_overlapping_bodies()
	for node: Node3D in nodes:
		if node is RigidBody3D:
			var body: RigidBody3D = node as RigidBody3D
			var direction_vector: Vector2 = direction_vectors[direction]
			var force: Vector3 = Vector3(-direction_vector.x, 0, -direction_vector.y)
			body.apply_force(body.mass * force * power)
