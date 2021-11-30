extends Control

onready var player = load("res://Player.tscn")

onready var multiplayer_config_ui = $MultiplayerConfig
onready var username_text_edit = $MultiplayerConfig/VBoxContainer/UsernameTextEdit
onready var device_ip_address = $CanvasLayer/DeviceIP
onready var start_game_button = $CanvasLayer/StartGameButton


func _ready() -> void:
	get_tree().connect("network_peer_connected",self,"_player_connected")
	get_tree().connect("network_peer_disconnected",self,"_player_disconnected")
	get_tree().connect("connected_to_server",self,"_connected_to_server")

	device_ip_address.text = Network.ip_address

	if get_tree().network_peer != null:
		pass
	else:
		start_game_button.hide()
func _process(delta) -> void:
	if get_tree().network_peer != null:
		if get_tree().get_network_connected_peers().size() >= 0 and get_tree().is_network_server():
			start_game_button.show()
		else:
			start_game_button.hide()

func instance_player(id) -> void:
	var player_instance = Global.instance_node_at_location(player,Persistents,Vector2(rand_range(0,1920),rand_range(0,1080)))
	player_instance.name=str(id)
	player_instance.set_network_master(id)

func _player_connected(id) -> void:
	print("Player " + str(id) + " connected")
	instance_player(id)

func _player_disconnected(id) -> void:
	print("Player " + str(id) + " disconnected")
	if Persistents.has_node(str(id)):
		Persistents.get_node(str(id)).queue_free()

func _connected_to_server() -> void:
	yield(get_tree().create_timer(0.1),"timeout")
	instance_player(get_tree().get_network_unique_id())

func _on_CreateServerButton_pressed():
	if username_text_edit.text != "":
		Network.current_player_username=username_text_edit.text
		multiplayer_config_ui.hide()
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
