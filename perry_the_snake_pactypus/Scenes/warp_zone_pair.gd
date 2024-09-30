extends Node2D

class_name WarpZonePair

@onready var zone_1: Area2D = $Zone1
@onready var zone_2: Area2D = $Zone2

@onready var zone_1_direction_marker: Marker2D = $Zone1/DirectionMarker
@onready var zone_2_direction_marker: Marker2D = $Zone2/DirectionMarker

var zone_1_enter_direction: Vector2
var zone_2_enter_direction: Vector2

func _ready():
	zone_1_enter_direction = (
		zone_1_direction_marker.global_position - zone_1.global_position
	).normalized().round()
	
	zone_2_enter_direction = (
		zone_2_direction_marker.global_position - zone_2.global_position
	).normalized().round()
	
	print(zone_1_enter_direction, zone_2_enter_direction)

func _on_zone_1_body_entered(body):
	# checks for perry
	if (body.is_in_group("player_head")):
		if (body.movement_direction != Vector2.LEFT):
			return
		body.global_position = zone_2.global_position - Vector2(40, 0)
		body.get_parent().create_new_chain()
	# doofs
	else:
		body.global_position = zone_2.global_position - Vector2(40, 0)

func _on_zone_2_body_entered(body):
	# checks for perry
	if (body.is_in_group("player_head")):
		if (body.movement_direction != Vector2.RIGHT):
			return
		body.global_position = zone_1.global_position + Vector2(40, 0)
		body.get_parent().create_new_chain()
	# doofs
	else:
		body.global_position = zone_1.global_position + Vector2(40, 0)
