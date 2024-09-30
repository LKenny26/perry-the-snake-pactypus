extends Node2D

# idea: disincentivize the player from staying still by decreasing thier length/score after a couple seconds

var body_segment_scene: PackedScene = load("res://Scenes/BodySegment.tscn")

var pellets = 0
var lives = 3
var cur_score = 0

@onready var player: Node2D = $Player
#var player: Node2D
@onready var pellets_list: Node = $Pellets
@onready var fedora: Node = $Big_Pellets
@onready var head: PlayerHead = $Player/PlayerHead

var start = Vector2.ZERO

var player_scene = load("res://Scenes/Player.tscn")

func _ready():
	#spawn_player()
	start.x = 500
	start.y = 580
	player.dead.connect(on_player_death)
	
	for pellet in pellets_list.get_children():
		pellet.pellet_eaten.connect(on_pellet_eaten)
	
	for fedoras in fedora.get_children():
		fedoras.fedora_eaten.connect(on_fedora_eaten)
	
	$Lives.text = "Lives: "
	$PelletCount.text = "Pellets Eaten: 0"
	$Length.text = "Length: 0"
	$Score.text = "Score: 0"

#When you eat a pellet it should...
func on_pellet_eaten(should_allow_eating_ghosts: bool):
	player.max_body_length += 20
	pellets = pellets + 1
	cur_score = cur_score + 100 + player.max_body_length / 2
	$PelletCount.text = "Pellets Eaten: " + str(pellets)
	$Length.text = "Length: " + str(player.max_body_length / 20)
	# pellets*100 + (player.max_body_length * 2 - 2) * 10
	$Score.text = "Score: " + str(cur_score)

#When you eat a fedora it should...
func on_fedora_eaten(should_allow_eating_ghosts: bool):
	if head:
		head.can_eat_doofs = true
		
		await get_tree().create_timer(10.0).timeout
		head.can_eat_doofs = false
	
func spawn_player():
	player = player_scene.instantiate()
	player.dead.connect(on_player_death)
	add_child(player)

func on_player_death():
	lives = lives - 1
	if lives == 2:
		$Life3.set_visible(false)
	elif lives == 1: 
		$Life2.set_visible(false)
	elif lives == 0:
		$Life1.set_visible(false)
		
	if lives > 0:
		await get_tree().create_timer(3.0).timeout
		player = player_scene.instantiate()
		player.dead.connect(on_player_death)
		player.position = start
		add_child(player)
	else: 
		$GameOver.text = "Game Over"
