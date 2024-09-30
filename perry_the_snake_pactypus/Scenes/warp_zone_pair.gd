extends Node2D

class_name WarpZonePair

@onready var zone_1: Area2D = $Zone1
@onready var zone_2: Area2D = $Zone2

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
