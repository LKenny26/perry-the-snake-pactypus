extends Node2D

# idea: disincentivize the player from staying still by decreasing thier length/score after a couple seconds

var body_segment_scene: PackedScene = load("res://Scenes/BodySegment.tscn")

var pellets = 0

@onready var player: Node2D = $Player
@onready var pellets_list: Node = $Pellets

func _ready():
	for pellet in pellets_list.get_children():
		pellet.pellet_eaten.connect(on_pellet_eaten)
		
	$Lives.text = "Lives: "
	$PelletCount.text = "Pellets Eaten: 0"
	$Length.text = "Length: 0"
	$Score.text = "Score: 0"

func on_pellet_eaten(should_allow_eating_ghosts: bool):
	player.max_body_length += 20
	pellets = pellets + 1
	$PelletCount.text = "Pellets Eaten: " + str(pellets)
	$Length.text = "Length: " + str(player.max_body_length)
	$Score.text = "Score: " + str(pellets*100 + (player.max_body_length * 2 - 2) * 10)
	
