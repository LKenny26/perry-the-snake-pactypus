extends CharacterBody2D

class_name PlayerHead

signal new_body_segment

# pacman stuff adapted from this tutorial: https://www.youtube.com/watch?v=CncJvOEM3OA&t=932s

var next_movement_direction: Vector2 = Vector2.ZERO
var movement_direction: Vector2 = Vector2.ZERO
var shape_query: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()

var previous_position: Vector2 = position		# updated each frame to calculate distance traveled
var distance_progress: int = 0				# how far the player has moved since the last segment was added
var segment_distance: int = 20 				# the distance between body segments

@export var speed: int = 175
@export var alive: bool = true				# whether the player is still playing/moving or has died

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var direction_pointer: Sprite2D = $DirectionPointer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	shape_query.shape = collision_shape_2d.shape
	shape_query.collision_mask = 2
	


func _physics_process(delta: float) -> void:
	if (!alive):
		return
	
	get_input()
	
	# player starts with no movement, so update instantly on first directional input
	if movement_direction == Vector2.ZERO:
		movement_direction = next_movement_direction
		
	# only update movement_direction when there's a gap in the walls
	if can_move_in_direction(next_movement_direction, delta):
		movement_direction = next_movement_direction
		sprite_2d.rotation = movement_direction.angle() #+ PI / 2 
	
	previous_position = position
	velocity = movement_direction * speed
	move_and_slide()
	
	# find the distance traveled between this frame and the last one
	var distance_traveled = (position - previous_position).length()
	
	# add to the distance progress; when it's over the segment distance, create a new one
	distance_progress += distance_traveled
	
	if (distance_progress >= segment_distance):
		new_body_segment.emit()
		distance_progress %= segment_distance
	
	
func get_input() -> void:
	var input_direction: Vector2
	
	if Input.is_action_pressed("left"):
		input_direction = Vector2.LEFT
		
	elif Input.is_action_pressed("right"):
		input_direction = Vector2.RIGHT
		
	elif Input.is_action_pressed("up"):
		input_direction = Vector2.UP
		
	elif Input.is_action_pressed("down"):
		input_direction = Vector2.DOWN
	
	# don't allow player to turn around 180 degrees
	if (input_direction && (input_direction + movement_direction) != Vector2.ZERO):
		next_movement_direction = input_direction
		
	# this is a visual indicator for the next direction the player wants to move
	if next_movement_direction != Vector2.ZERO:
		direction_pointer.position = next_movement_direction * direction_pointer.position.length()
		if next_movement_direction == Vector2.RIGHT:
			direction_pointer.rotation_degrees = 0
		elif next_movement_direction == Vector2.DOWN:
			direction_pointer.rotation_degrees = 90
		elif next_movement_direction == Vector2.LEFT:
			direction_pointer.rotation_degrees = 180
		else:
			direction_pointer.rotation_degrees = 270
	
		
# kinda "raycasts" a shape into the next direction to see if theres a wall there
func can_move_in_direction(dir: Vector2, delta: float) -> bool:
	shape_query.transform = global_transform.translated(dir * speed * delta * 2)
	var result = get_world_2d().direct_space_state.intersect_shape(shape_query)
	return result.size() == 0
