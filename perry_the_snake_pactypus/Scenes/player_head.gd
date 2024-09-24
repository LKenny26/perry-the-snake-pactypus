extends CharacterBody2D

class_name PlayerHead

signal new_body_point

# pacman stuff adapted from this tutorial: https://www.youtube.com/watch?v=CncJvOEM3OA&t=932s

var next_movement_direction: Vector2 = Vector2.ZERO
var movement_direction: Vector2 = Vector2.ZERO
var shape_query: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()

@export var speed: int = 150
@export var alive: bool = true				# whether the player is still playing/moving or has died

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var direction_pointer: Sprite2D = $DirectionPointer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	shape_query.shape = collision_shape_2d.shape
	shape_query.collision_mask = 2


func _physics_process(delta: float) -> void:
	var turning = false
	
	#if (!alive):
		#return
	
	get_input()
		
	# only update movement_direction when there's a gap in the walls
	if can_move_in_direction(next_movement_direction, delta) && movement_direction != next_movement_direction:
		movement_direction = next_movement_direction
		sprite.rotation = movement_direction.angle() #+ PI / 2 
		
		turning = true
		
	
	velocity = movement_direction * speed
	
	# captures collision
	var collision = move_and_collide(velocity*delta)
	
	# checks to see if collided with doof
	if collision and collision.get_collider().is_in_group("doofs"):
		self.alive = false
	
	# snaps the player to the grid so it's never off center. Also, create new point
	if turning:
		global_position.x = round((global_position.x - 20) / 40) * 40 + 20
		global_position.y = round((global_position.y - 20) / 40) * 40 + 20
		new_body_point.emit()
	
	
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
		direction_pointer.rotation = next_movement_direction.angle()
	
		
# kinda "raycasts" a shape into the next direction to see if theres a wall there
func can_move_in_direction(dir: Vector2, delta: float) -> bool:
	shape_query.transform = global_transform.translated(dir * speed * delta * 2)
	var result = get_world_2d().direct_space_state.intersect_shape(shape_query)
	return result.size() == 0
