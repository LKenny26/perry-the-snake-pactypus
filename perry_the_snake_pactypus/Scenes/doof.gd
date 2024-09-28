extends CharacterBody2D

@export var speed: int = 100

var player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_nodes_in_group("player_head")[0]
	call_deferred("actor_setup")
	$Timer.start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Processing that requires physics ("moving stuff") values
func _physics_process(delta: float) -> void:
	# calculates speed and dir of doof to get to the next point in the path
	# Navigation Agent figures out path for doof to follow
	set_velocity(global_position.direction_to($NavigationAgent2D.get_next_path_position()) * speed)
	move_and_slide()

func actor_setup():
	var pos
	# if player is dead, chooses a random position
	if !player:
		pos = Vector2(randi_range(0, 1000), randi_range(0,1000))
	else:
		player = get_tree().get_nodes_in_group("player_head")[0] # reinitialize player
		pos = player.global_position # gets player's head position
	
	await get_tree().physics_frame # waits for the first physics frame before starting to move
	$NavigationAgent2D.target_position = pos # sets doofs random target position to randomly generated vector

# chooses a new random coordinate after 7 seconds
func _on_timer_timeout():
	var pos
	if !player:
		pos = Vector2(randi_range(0, 1000), randi_range(0,1000))
	else:
		pos = player.global_position
		
	$NavigationAgent2D.target_position = pos
	$Timer.start()
	
# chooses a new random coordinate if the destination was reached
func _on_navigation_agent_2d_navigation_finished() -> void:
	var pos
	if !player:
		pos = Vector2(randi_range(0, 1000), randi_range(0,1000))
	else:
		pos = player.global_position
		
	$NavigationAgent2D.target_position = pos
	$Timer.start()
