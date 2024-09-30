extends Node2D

# idea: disincentivize the player from staying still by decreasing thier length/score after a couple seconds

var pellets = 0
var lives = 3
var cur_score = 0

@onready var player: Node2D = $Player
#var player: Node2D
#@onready var pellets_list: Node = $Pellets
var start = Vector2.ZERO

var player_scene = load("res://Scenes/Player/Player.tscn")

var level1_scene: PackedScene = load("res://Scenes/Levels/Level1.tscn")
var level2_scene: PackedScene = load("res://Scenes/Levels/Level2.tscn")

var levels: Array[PackedScene] = [level1_scene, level2_scene]


func load_level(number: int):
	var previous_level: Node = get_child(0)
	if previous_level is Level:
		previous_level.queue_free()
	
	var level: Level = levels[number - 1].instantiate()
	add_child(level)
	move_child(level, 0)
	call_deferred("set_up_pellets", level)


func set_up_pellets(level: Level):
	var pellet_layer: TileMapLayer = level.get_node("NavigationRegion2D/PelletLayer")
	
	for pellet in pellet_layer.get_children():
		pellet.pellet_eaten.connect(on_pellet_eaten)


func _ready():
	load_level(1)
	
	start.x = 500
	start.y = 580
	player.dead.connect(on_player_death)
		
	$Lives.text = "Lives: "
	$PelletCount.text = "Pellets Eaten: 0"
	$Length.text = "Length: 0"
	$Score.text = "Score: 0"


func on_pellet_eaten(should_allow_eating_ghosts: bool):
	player.max_body_length += 20
	pellets = pellets + 1
	cur_score = cur_score + 100 + player.max_body_length / 2
	$PelletCount.text = "Pellets Eaten: " + str(pellets)
	$Length.text = "Length: " + str(player.max_body_length / 20)
	$Score.text = "Score: " + str(cur_score)
	
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
