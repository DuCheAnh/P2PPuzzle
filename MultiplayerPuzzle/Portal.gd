extends Area2D

export (String, FILE) var scene = ""

func _on_Portal_body_entered(body):
	if is_network_master():
		if body.is_in_group("Player"):
			if scene != "":
				rpc("change_map")
sync func change_map() -> void:
			get_tree().change_scene(scene)
