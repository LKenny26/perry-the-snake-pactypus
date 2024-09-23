extends Node2D

var body_segment_scene: PackedScene = load("res://Scenes/BodySegment.tscn")

# max length the player can be (until the eat more pellets)
@export var max_body_length: float = 40

@onready var player_head: PlayerHead = $PlayerHead

@onready var body_line: Line2D = $BodyLine					# visual only - the colored line
@onready var body_line_border: Line2D = $BodyLineBorder		# visual only - the black border
@onready var body_segment_list: Node2D = $BodySegmentList		# list of actual colliders

# list of points that make up the body. There is one point at each corner/joint,
# one at the head and one at the tail. The ones at the ends update each frame so
# that the movement looks smooth. The three nodes above all rely on this list.
var body_points: PackedVector2Array = PackedVector2Array()

# signal for main to show it has died
signal dead

# creates a new collider line between the last and second to last points
func create_new_body_segment():
	var new_segment = body_segment_scene.instantiate()
	var segment_collider = new_segment.get_node("CollisionShape2D")
	
	segment_collider.global_position = Vector2.ZERO
	segment_collider.shape = SegmentShape2D.new()
	segment_collider.shape.a = body_points[body_points.size() - 2]
	segment_collider.shape.b = body_points[body_points.size() - 1]
	
	body_segment_list.add_child(new_segment)

func update_body_lines():
	body_line.points = body_points
	body_line_border.points = body_points

func _ready():
	body_line.global_position = Vector2.ZERO
	body_line_border.global_position = Vector2.ZERO
	body_segment_list.global_position = Vector2.ZERO
	
	body_points.append(player_head.global_position + Vector2.LEFT * 40)
	body_points.append(player_head.global_position)
	create_new_body_segment()
	
func death():
	queue_free()
	emit_signal("dead")
	
func _process(delta: float):
	# if not alive free perry
	if !player_head.alive:
		self.death()
	
	# update the last point in the list to the player's head position
	body_points[body_points.size() - 1] = player_head.global_position
	
	# update the first point in the list to the player's tail position
	var last_collider = body_segment_list.get_child(body_segment_list.get_child_count() - 1).get_node("CollisionShape2D")
	last_collider.shape.b = body_points[body_points.size() - 1]
	
	# if the player isn't at their max length, let them grow by leaving the last point in place
	if get_body_length() < max_body_length:
		update_body_lines()
		return
	
	# otherwise, move the last point so that the total length is the same
	var first_point: Vector2 = body_points[0]
	var second_point: Vector2 = body_points[1]
	var direction: Vector2 = (second_point - first_point).normalized()
	body_points[0] = first_point + direction * player_head.speed * delta
	
	# update collider
	var first = body_segment_list.get_child(0)
	var first_collider = first.get_node("CollisionShape2D")
	first_collider.shape.a = body_points[0]
	
	# if the first two points are very close, delete the first point. This happens
	# when the moving tail rounds a corner.
	if (abs(body_points[0].distance_to(body_points[1])) < 10):
		body_points.remove_at(0)
		first.queue_free()
	
	update_body_lines()

# create a new body point, this happens whenever the moving head rounds a corner
func _on_player_head_new_body_point():
	body_points.insert(body_points.size() - 1, player_head.global_position)
	create_new_body_segment()
	update_body_lines()
	
# calculates the total length of the player
func get_body_length() -> int:
	var length: int = 0
	
	for i in range(body_points.size() - 1):
		length += body_points[i].distance_to(body_points[i + 1])
		
	return length
