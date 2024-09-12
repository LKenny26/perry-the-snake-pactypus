extends Node2D

# idea: disincentivize the player from staying still by decreasing thier length/score after a couple seconds

# the max number of segments the player can have at once (till they grow)
var body_length: float = 1.0

var body_segment_scene: PackedScene = load("res://Scenes/BodySegment.tscn")

@onready var player: PlayerHead = $PlayerHead
@onready var body_segments_list: Node2D = $BodySegmentsList
@onready var pellets_list: Node = $Pellets

func _on_player_new_body_segment():
	
	# create a new body segment at the player's position and add it to the list
	var new_body_segment: Area2D = body_segment_scene.instantiate()
	new_body_segment.position = player.position
	body_segments_list.add_child(new_body_segment)

	# if there are now more than the max length, remove the last (aka first created) segment.
	# body_segments_list is pretty much a queue with a fixed length
	if (body_segments_list.get_child_count() > body_length):
		var last_body_segment: Area2D = body_segments_list.get_child(0)
		last_body_segment.queue_free()

func _ready():
	for pellet in pellets_list.get_children():
		pellet.pellet_eaten.connect(on_pellet_eaten)

func on_pellet_eaten(should_allow_eating_ghosts: bool):
	body_length += .2
	
