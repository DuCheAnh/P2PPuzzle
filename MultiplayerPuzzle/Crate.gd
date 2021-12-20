extends KinematicBody2D


puppet var puppet_position setget puppet_position_set
puppet var puppet_velocity

var gravity = 4000
var last_pos
var movement = Vector2.ZERO
func _ready():
	last_pos = global_position

func _physics_process(delta):
	if last_pos.x == global_position.x:
		movement.y += gravity * delta
		movement = move_and_slide(movement)
	last_pos = global_position




func push(velocity) -> void:
	move_and_slide(velocity)
	if is_network_master():
		rset("puppet_position",global_position)




func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	if not is_network_master():
		global_position.linear_interpolate(puppet_position, 5)
