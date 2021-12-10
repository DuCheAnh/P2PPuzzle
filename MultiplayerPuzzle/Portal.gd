extends Area2D

export (String, FILE) var scene = ""

func _on_Portal_body_entered(body):
	if body.is_in_group("Player"):
		if scene != "":
			get_tree().change_scene(scene)
