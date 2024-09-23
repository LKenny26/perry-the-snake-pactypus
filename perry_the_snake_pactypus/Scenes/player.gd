extends StaticBody2D

@export var max_body_length: float = 40

@onready var player_head: PlayerHead = $PlayerHead
@onready var body_line: Line2D = $BodyLine
@onready var body_line_border: Line2D = $BodyLineBorder
@onready var body_collision_shape_list: Node2D = $BodyCollisionShapeList

var body_points: PackedVector2Array = PackedVector2Array()

func create_new_body_collision_shape():
	var segment_shape = SegmentShape2D.new()
	segment_shape.a = body_points[body_points.size() - 2]
	segment_shape.b = body_points[body_points.size() - 1]
	
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = segment_shape
	collision_shape.global_position = Vector2.ZERO
	body_collision_shape_list.add_child(collision_shape)

func update_body():
	body_line.points = body_points
	body_line_border.points = body_points
	
	#body_collision_shape_list.queue_free()
	#body_collision_shape_list = Node2D.new()
	
	#for i in range(body_points.size() - 1):
		#var segment_shape = SegmentShape2D.new()
		#segment_shape.a = body_points[i]
		#segment_shape.b = body_points[i + 1]
		#
		#var collision_shape = CollisionShape2D.new()
		#collision_shape.shape = segment_shape
		#collision_shape.global_position = Vector2.ZERO
		#body_collision_shape_list.add_child(collision_shape)

func _ready():
	body_line.global_position = Vector2.ZERO
	body_line_border.global_position = Vector2.ZERO
	body_collision_shape_list.global_position = Vector2.ZERO
	
	body_points.append(player_head.global_position + Vector2.LEFT * 40)
	body_points.append(player_head.global_position)
	create_new_body_collision_shape()
	
	update_body()
	
	
func _process(delta: float):
	body_points.remove_at(body_points.size() - 1)
	body_points.append(player_head.global_position)
	#body_line.points = body_points
	
	if get_body_length() < max_body_length:
		update_body()
		return
	
	var first_point: Vector2 = body_points[0]
	var second_point: Vector2 = body_points[1]
	var direction: Vector2 = (second_point - first_point).normalized()
	body_points[0] = first_point + direction * player_head.speed * delta
	
	if (abs(body_points[0].distance_to(body_points[1])) < 10):
		body_points.remove_at(0)
	
	update_body()

func _on_player_head_new_body_point():
	print(player_head.global_position)
	body_points.insert(body_points.size() - 1, player_head.global_position)
	create_new_body_collision_shape()
	update_body()
	
func get_body_length() -> int:
	var length: int = 0
	
	for i in range(body_points.size() - 1):
		length += body_points[i].distance_to(body_points[i + 1])
		
	return length
