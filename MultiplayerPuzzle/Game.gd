extends Node2D
export (float) var limit_right = 1000000
export (float) var limit_bottom = 1000000
export (float) var limit_left = 0
export (float) var limit_top = 0
var current_player = null
func _ready() -> void:
	get_tree().connect("network_peer_disconnected",self,"_player_disconnected")
	if get_tree().has_network_peer():
		if get_tree().is_network_server():
			rpc("apply_camera_limit")
			rpc("reset_map", false)

func _process(delta) -> void:
	if get_tree().has_network_peer():
		if get_tree().is_network_server():
			if Global.someone_is_dead:
				rpc("reset_map", true)
#need more work
sync func reset_map(reload_map : bool) -> void:
	if reload_map:
		get_tree().reload_current_scene()
	Global.someone_is_dead = false
	var spawn_point = 128
	for child in Persistents.get_children():
		if child.is_in_group("Player"):
			child.dead = false
			spawn_point += 256
			child.rpc("update_player_position",Vector2(spawn_point, 256))


sync func apply_camera_limit() -> void:
	for object in Persistents.get_children():
		if object.is_in_group("Player"):
			object.set_cam_limit(limit_left, limit_top, limit_right, limit_bottom)

func _player_disconnected(id) -> void:
	print("player " + str(id) + " disconnected")
	if Persistents.has_node(str(id)):
		Persistents.get_node(str(id)).username_text_instance.queue_free()
		Persistents.get_node(str(id)).queue_free()



