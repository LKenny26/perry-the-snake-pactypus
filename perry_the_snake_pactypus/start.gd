extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Button.started.connect(hide_me)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func hide_me() -> void:	
	visible = false
	var main_scene = preload("res://Scenes/Main.tscn").instantiate()
	if($CheckButton.button_pressed == true):
		main_scene.toggle_nux()
	get_tree().root.add_child(main_scene)
