extends CharacterBody2D

@export var speed: int = 110

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	await get_tree().physics_frame # waits for the first physics frame before starting to move
	var pos = Vector2(randi_range(0, 1000), randi_range(0, 1000)) # generates random point in map
	$NavigationAgent2D.target_position = pos # sets doofs random target position to randomly generated vector

# chooses a new random coordinate after 7 seconds
func _on_timer_timeout():
	var pos = Vector2(randi_range(0, 1000), randi_range(0, 1000))
	$NavigationAgent2D.target_position = pos
	$Timer.start()
	
# chooses a new random coordinate if the destination was reached
func _on_navigation_agent_2d_navigation_finished() -> void:
	var pos = Vector2(randi_range(0, 1000), randi_range(0, 1000))
	$NavigationAgent2D.target_position = pos
	$Timer.start()
