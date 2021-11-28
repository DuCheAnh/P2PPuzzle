extends Control

onready var server_listener = $ServerListener
onready var manual_vbox = $BackgroundPanel/ManualVBox
onready var server_ip_text_edit = $BackgroundPanel/ManualVBox/ServerIPTextEdit
onready var server_container = $BackgroundPanel/ServerContainer
onready var manual_setup_button = $BackgroundPanel/ManualSetupButton
func _ready() -> void:
	manual_vbox.hide()


func _on_ServerListener_new_server(serverInfo):
	var server_node = Global.instance_node(load("res://ServerDisplay.tscn"),server_container)
	server_node.text = "%s - %s" % [serverInfo.ip, serverInfo.name]
	server_node.ip_address = str(serverInfo.ip)


func _on_ServerListener_remove_server(serverIP):
	for serverNode in server_container.get_children():
		if serverNode.is_in_group("Server_display"):
			if serverNode.ip_address == serverIP:
				serverNode.queue_free()
				break


func _on_ManualSetupButton_pressed():
	if manual_setup_button.text != "exit setup":
		manual_vbox.show()
		manual_setup_button.text = "exit setup"
		server_container.hide()
		server_ip_text_edit.call_deferred("grab_focus")
	else:
		server_ip_text_edit.text = ""
		manual_vbox.hide()
		manual_setup_button.text = "manual setup"
		server_container.show()



func _on_JoinServerButton_pressed():
	Network.ip_address = server_ip_text_edit.text
	hide()
	Network.join_server()

func _on_GoBackButton_pressed():
	get_tree().reload_current_scene()
