extends Node

var client = null
var server = null

var ip_address = ""
var current_player_username = ""

func _ready() -> void:
	if OS.get_name() == "Windows":
		ip_address = IP.get_local_addresses()[3]
	elif OS.get_name() == "Android":
		ip_address = IP.get_local_addresses()[0]
	else:
		ip_address = IP.get_local_addresses()[3]

	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168.") and not ip.ends_with(".1"):
			ip_address = ip

	get_tree().connect("connected_to_server",self,"_connected_to_server")
	get_tree().connect("server_disconnected",self,"_server_disconnected")
	get_tree().connect("connection_failed",self,"_connection_failed")

func reset_network_connection() -> void:
	if get_tree().has_network_peer():
		get_tree().network_peer = null

func create_server() -> void:
	server = NetworkedMultiplayerENet.new()
	server.create_server(Global.DEFAULT_PORT,Global.MAX_CLIENT)
	get_tree().set_network_peer(server)
	Global.instance_node(load("res://ServerAdvertiser.tscn"),get_tree().current_scene)

func join_server() -> void:
	client = NetworkedMultiplayerENet.new()
	client.create_client(ip_address,Global.DEFAULT_PORT)
	get_tree().set_network_peer(client)

func _connection_failed() -> void:
	for child in Persistents.get_children():
		if child.is_in_group("Net"):
			child.queue_free()

	reset_network_connection()

	if Global.ui != null:
		var prompt = Global.instance_node(load("res://SimplePrompt.tscn"), Global.ui)
		prompt.set_text("Failed to connect server")

func _connected_to_server() -> void:
	print("connected to server")

func _server_disconnected() -> void:
	print("disconnected from server")

	for child in Persistents.get_children():
		if child.is_in_group("Net"):
			child.queue_free()

	reset_network_connection()
	if Global.ui != null:
		var prompt = Global.instance_node(load("res://SimplePrompt.tscn"), Global.ui)
		prompt.set_text("Disconnected from server")
