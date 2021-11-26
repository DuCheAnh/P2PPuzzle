extends Control

onready var multiplayer_config_ui = $MultiplayerConfig
onready var server_ip_address = $MultiplayerConfig/VBoxContainer/ServerIP
onready var device_ip_address = $CanvasLayer/DeviceIP

func _ready() -> void:
	get_tree().connect("network_peer_connected",self,"_player_connected")
	get_tree().connect("network_peer_disconnected",self,"_player_disconnected")
	get_tree().connect("connected_to_server",self,"_connected_to_server")

	device_ip_address.text = Network.ip_address

func _player_connected(id) -> void:
	print("Player " + str(id) + " connected")

func _player_disconnected(id) -> void:
	print("Player " + str(id) + " disconnected")


func _on_CreateServerButton_pressed():
	multiplayer_config_ui.hide()
	Network.create_server()

func _on_JoinServerButton_pressed():
	if server_ip_address.text != "":
		multiplayer_config_ui.hide()
		Network.ip_address  = server_ip_address.text
		Network.join_server()
