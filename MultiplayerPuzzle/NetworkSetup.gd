extends Control

onready var player = load("res://Player.tscn")

onready var multiplayer_config_ui = $MultiplayerConfig
onready var username_text_edit = $MultiplayerConfig/VBoxContainer/UsernameTextEdit
onready var device_ip_address = $UI/DeviceIP
onready var start_game_button = $UI/StartGameButton
onready var tile_map = $TileMap

func _ready() -> void:
	get_tree().connect("network_peer_connected",self,"_player_connected")
	get_tree().connect("network_peer_disconnected",self,"_player_disconnected")
	get_tree().connect("connected_to_server",self,"_connected_to_server")
	tile_map.visible = false
	device_ip_address.text = Network.ip_address
	if get_tree().network_peer != null:
		multiplayer_config_ui.hide()
	else:
		start_game_button.hide()

func _process(delta) -> void:
	if get_tree().network_peer != null:
		if get_tree().get_network_connected_peers().size() >= 0 and get_tree().is_network_server():
			start_game_button.show()
		else:
			start_game_button.hide()


puppet func show_tile_map():
	tile_map.visible = true

func instance_player(id) -> void:
	var player_instance = Global.instance_node_at_location(player,Persistents,Vector2(rand_range(200,1500),256))
	player_instance.name=str(id)
	player_instance.set_network_master(id)
	player_instance.username = username_text_edit.text



func _player_connected(id) -> void:
	if is_network_master():
		Global.display_notification("Player " + str(id) + " connected")
	if get_tree().has_network_peer():
		if get_tree().is_network_server():
			rpc("show_tile_map")
	instance_player(id)

func _player_disconnected(id) -> void:
	if is_network_master():
		Global.display_notification("Player " + str(id) + " disconnected")
	if Persistents.has_node(str(id)):
		Persistents.get_node(str(id)).username_text_instance.queue_free()
		Persistents.get_node(str(id)).queue_free()

func _connected_to_server() -> void:
	yield(get_tree().create_timer(0.1),"timeout")
	instance_player(get_tree().get_network_unique_id())



func _on_CreateServerButton_pressed():
	if username_text_edit.text != "":
		Network.current_player_username=username_text_edit.text
		multiplayer_config_ui.hide()
		tile_map.visible = true
		Network.create_server()
		instance_player(get_tree().get_network_unique_id())

func _on_JoinServerButton_pressed():
	if username_text_edit.text != "":
		multiplayer_config_ui.hide()
		Global.instance_node(load("res://ServerBrowser.tscn"),self)



func _on_StartGameButton_pressed():
	rpc("switch_to_game")

sync func switch_to_game() -> void:
	get_tree().change_scene("res://Game.tscn")
