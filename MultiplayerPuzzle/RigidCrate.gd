extends RigidBody2D

puppet var puppet_position setget puppet_position_set

func _process(delta):
	if is_network_master():
		rset("puppet_position", global_position)


func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	if not is_network_master():
		global_position = puppet_position

