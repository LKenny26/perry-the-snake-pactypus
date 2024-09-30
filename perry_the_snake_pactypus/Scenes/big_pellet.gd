extends Area2D

#Taken from https://www.youtube.com/watch?v=CncJvOEM3OA

class_name Big_Pellet

signal fedora_eaten(should_allow_eating_ghosts: bool)

@export var should_allow_eating_ghosts = true

func _on_body_entered(body):
	print('fed')
	if body is PlayerHead:
		fedora_eaten.emit(should_allow_eating_ghosts)
		queue_free()
