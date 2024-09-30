extends Node2D

var body_chain_scene: PackedScene = load("res://Scenes/Player/BodyChain.tscn")

# max length the player can be (until the eat more pellets)
@export var max_body_length: float = 40

@onready var player_head: PlayerHead = $PlayerHead
@onready var body_chain_list: Node2D = $BodyChainList

# signal for main to show it has died
signal dead
	
func death():
	emit_signal("dead")
	queue_free()
	
	
func _process(delta: float):
	# if not alive free perry
	if !player_head.alive:
		self.death()
	
	var last_chain: BodyChain = body_chain_list.get_child(body_chain_list.get_child_count() - 1)
	last_chain.update_head()
	
	# if the player isn't at their max length, let them grow by leaving the last point in place
	if get_body_length() < max_body_length:
		return
	
	var first_chain: BodyChain = body_chain_list.get_child(0)
	first_chain.update_tail(delta)
	
	if first_chain != last_chain:
		first_chain.body_line.end_cap_mode = Line2D.LINE_CAP_BOX
		first_chain.body_line_border.end_cap_mode = Line2D.LINE_CAP_BOX
		last_chain.body_line.begin_cap_mode = Line2D.LINE_CAP_BOX
		last_chain.body_line_border.begin_cap_mode = Line2D.LINE_CAP_BOX
	else:
		first_chain.body_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		first_chain.body_line.end_cap_mode = Line2D.LINE_CAP_ROUND
		first_chain.body_line_border.begin_cap_mode = Line2D.LINE_CAP_ROUND
		first_chain.body_line_border.end_cap_mode = Line2D.LINE_CAP_ROUND

# create a new body point, this happens whenever the moving head rounds a corner
func _on_player_head_new_body_point():
	var last_chain: BodyChain = body_chain_list.get_child(body_chain_list.get_child_count() - 1)
	last_chain.new_body_point()
	
func create_new_chain():
	var new_chain: BodyChain = body_chain_scene.instantiate()
	body_chain_list.add_child(new_chain)
	
# calculates the total length of the player
func get_body_length() -> int:
	var length: int = 0
	
	for chain in body_chain_list.get_children():
		length += chain.get_chain_length()
		
	return length
