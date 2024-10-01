extends Node2D

# idea: disincentivize the player from staying still by decreasing thier length/score after a couple seconds
var pellets = 0
var lives = 3
var cur_score = 0
var current_level_number = 1

signal endGame

@onready var player: Node2D = $Player
@onready var player_head: PlayerHead = $Player/PlayerHead
@onready var current_level: Level = get_child(0)

@onready var life_icons: Node2D = $LifeIcons
@onready var level_clear_text: Label = $LevelClear

#var player: Node2D
#@onready var pellets_list: Node = $Pellets
var start = Vector2.ZERO
var previous_length: int = 40

var life_icon_scene: PackedScene = load("res://Scenes/life_icon.tscn")
var player_scene: PackedScene = load("res://Scenes/Player/Player.tscn")

var level1_scene: PackedScene = load("res://Scenes/Levels/Level1.tscn")
var level2_scene: PackedScene = load("res://Scenes/Levels/Level2.tscn")
var level3_scene: PackedScene = load("res://Scenes/Levels/Level3.tscn")

var levels: Array[PackedScene] = [level1_scene, level2_scene, level3_scene]


func load_level(number: int):
	#var previous_level: Node = get_child(0)
	if current_level is Level:
		current_level.queue_free()
		
	current_level = levels[number - 1].instantiate()
	add_child(current_level)
	move_child(current_level, 0)
	call_deferred("set_up_pellets", current_level)

func toggle_nux():
	lives = 14

func set_up_pellets(level: Level):
	var pellet_layer: TileMapLayer = level.get_node("NavigationRegion2D/PelletLayer")
	
	for item in pellet_layer.get_children():
		if item is Pellet:
			item.pellet_eaten.connect(on_pellet_eaten)
		if item is Big_Pellet:
			print(item)
			item.fedora_eaten.connect(on_fedora_eaten)


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
	$Wakawaka.play()
	player.max_body_length += 20
	pellets = pellets + 1
	cur_score = cur_score + 100 + player.max_body_length / 2
	$PelletCount.text = "Pellets Eaten: " + str(pellets)
	$Length.text = "Length: " + str(player.max_body_length / 20)
	$Score.text = "Score: " + str(cur_score)
	
	var pellet_layer = current_level.get_node("NavigationRegion2D/PelletLayer")
	
	if (pellet_layer.get_child_count() <= 1):
		level_clear_text.visible = true
		await get_tree().create_timer(2.0).timeout
		level_clear_text.visible = false
		current_level_number += 1
		
		if current_level_number > levels.size():
			return
		
		load_level(current_level_number)
		spawn_player(current_level.get_node("SpawnPosition").position, true)
		
		
#When you eat a fedora it should...
func on_fedora_eaten(should_allow_eating_ghosts: bool):
	player_head.can_eat_doofs = true
	player_head.fedora_sprite.visible = true
	$PerryAudio.play()
	await get_tree().create_timer(10.0).timeout
	if is_instance_valid(player_head): # checks if player head exists
		player_head.can_eat_doofs = false
		player_head.fedora_sprite.visible = false
	
func spawn_player(spawn_position: Vector2, new_level: bool):
	if player != null:
		player.queue_free()
		 
	player = player_scene.instantiate()
	player_head = player.get_node("PlayerHead")
	player.dead.connect(on_player_death)
	player.position = spawn_position
	
	add_child(player)

func on_player_death(body_length: int):
	previous_length = body_length
	lives -= 1
	life_icons.get_child(lives).set_visible(false)
		
	if lives > 0:
		await get_tree().create_timer(3.0).timeout
		spawn_player(current_level.get_node("SpawnPosition").position, false)
		for doof in current_level.get_node("Doofs").get_children():
			doof.player = get_tree().get_nodes_in_group("player_head")[0] # reassigns player to Doof
	
	else: 
		$GameOver.text = "Game Over\nEnd Score: " + str(cur_score)
		await get_tree().create_timer(5).timeout
		emit_signal("endGame")
		queue_free()
		
		
func _on_audio_stream_player_2d_finished() -> void:
	if randi_range(0, 9) == 0:
		$SecretAudioLoop.playing = true
	else:
		$AudioLoop.playing = true
