extends Node2D

func _ready() -> void:
	get_tree().connect("network_peer_disconnected",self,"_player_disconnected")

func _process(delta) -> void:
	if get_tree().has_network_peer():
		if get_tree().is_network_server():
			if Global.someone_is_dead:
				rpc("reset_map")
#need more work
sync func reset_map() -> void:
	get_tree().reload_current_scene()
	Global.someone_is_dead = false
	var spawn_point = 128
	for child in Persistents.get_children():
		if child.is_in_group("Player"):
			spawn_point += 256
			child.rpc("update_player_position",Vector2(spawn_point, 256))

func _player_disconnected(id) -> void:
	print("player " + str(id) + " disconnected")
	if Persistents.has_node(str(id)):
		Persistents.get_node(str(id)).username_text_instance.queue_free()
		Persistents.get_node(str(id)).queue_free()

