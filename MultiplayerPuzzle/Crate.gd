extends KinematicBody2D


puppet var puppet_position setget puppet_position_set
puppet var puppet_velocity
func push(velocity) -> void:
	move_and_slide(velocity)
	if is_network_master():
		rset_unreliable("puppet_position",global_position)




func puppet_position_set(new_value) -> void:
	puppet_position = new_value
#	if not is_network_master():
#		$Tween.interpolate_property(self,"global_position",global_position,puppet_position,0.01)
#		$Tween.start()
	global_position = puppet_position
