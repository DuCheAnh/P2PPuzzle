extends KinematicBody2D

var velocity = null
puppet var puppet_position setget puppet_position_set
func push(velocity) -> void:
	if is_network_master():
		rset_unreliable("puppet_position",global_position)
	move_and_slide(velocity)




func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	if not is_network_master():
#		$Tween.interpolate_property(self,"global_position",global_position,puppet_position,0.05)
#		$Tween.start()
		global_position = puppet_position
