extends Node

const DEFAULT_PORT = 28960
const MAX_CLIENT = 6

var ui = null
var someone_is_dead = false

func instance_node(node: Object, parent: Object) -> Object:
	var node_instance=node.instance()
	parent.add_child(node_instance)
	return node_instance

func instance_node_at_location(node: Object, parent: Object, location: Vector2) -> Object:
	var node_instance=instance_node(node,parent)
	node_instance.global_position=location
	return node_instance

func display_notification(message) -> void:
	var prompt = Global.instance_node(load("res://MessageLabel.tscn"), Global.ui)
	prompt.set_message(message)

func display_keyboard_notification(message) -> void:
	var prompt = Global.instance_node(load("res://MessageLabel.tscn"), Global.ui)
	prompt.rect_position = Vector2(100,1000)
	prompt.set_message(message)
