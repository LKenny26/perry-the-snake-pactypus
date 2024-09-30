extends Node2D

# idea: disincentivize the player from staying still by decreasing thier length/score after a couple seconds

var pellets = 0
var lives = 14
var cur_score = 0
var current_level_number = 1

@onready var player: Node2D = $Player
@onready var current_level: Level = get_child(0)

@onready var life_icons: Node2D = $LifeIcons

#var player: Node2D
#@onready var pellets_list: Node = $Pellets
var start = Vector2.ZERO


var life_icon_scene: PackedScene = load("res://Scenes/life_icon.tscn")
var player_scene: PackedScene = load("res://Scenes/Player/Player.tscn")

var level1_scene: PackedScene = load("res://Scenes/Levels/Level1.tscn")
var level2_scene: PackedScene = load("res://Scenes/Levels/Level2.tscn")

var levels: Array[PackedScene] = [level1_scene, level2_scene]


func load_level(number: int):
	#var previous_level: Node = get_child(0)
	if current_level is Level:
		current_level.queue_free()
		
	current_level = levels[number - 1].instantiate()
	add_child(current_level)
	move_child(current_level, 0)
	call_deferred("set_up_pellets", current_level)


func set_up_pellets(level: Level):
	var pellet_layer: TileMapLayer = level.get_node("NavigationRegion2D/PelletLayer")
	
	for pellet in pellet_layer.get_children():
		pellet.pellet_eaten.connect(on_pellet_eaten)


func _ready():
	load_level(current_level_number)
	
	start.x = 500
	start.y = 580
	player.dead.connect(on_player_death)
	
	for i in range(lives):
		var life_icon = life_icon_scene.instantiate()
		life_icon.global_position = Vector2(i * 60 + 170, 970)
		life_icons.add_child(life_icon)
		
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
	
	var pellet_layer = current_level.get_node("NavigationRegion2D/PelletLayer")
	print(pellet_layer.get_child_count())
	if (pellet_layer.get_child_count() <= 1):
		await get_tree().create_timer(2.0).timeout
		current_level_number += 1
		load_level(current_level_number)
		spawn_player()
		await get_tree().create_timer(3.0).timeout
		
	
func spawn_player():
	if player != null:
		player.queue_free()
		 
	player = player_scene.instantiate()
	player.dead.connect(on_player_death)
	player.position = start
	add_child(player)

func on_player_death():
	lives -= 1
	life_icons.get_child(lives).set_visible(false)
	
	#if lives == 2:
		#$Life3.set_visible(false)
	#elif lives == 1: 
		#$Life2.set_visible(false)
	#elif lives == 0:
		#$Life1.set_visible(false)
		
	if lives > 0:
		await get_tree().create_timer(3.0).timeout
		spawn_player()
		#player = player_scene.instantiate()
		#player.dead.connect(on_player_death)
		#player.position = start
		#add_child(player)
	else: 
		$GameOver.text = "Game Over"
