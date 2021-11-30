extends Area2D



func _on_TestBlock_body_entered(body):
	if body.is_in_group("Player"):
		if body.is_on_floor():
			body.jump(1)

