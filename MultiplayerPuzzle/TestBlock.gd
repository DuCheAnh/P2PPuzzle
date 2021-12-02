extends Area2D

export (float) var multiplier = 1

func _on_TestBlock_body_entered(body):
	if body.is_in_group("Player"):
		$Sprite.play("pressed")
		$Sprite.scale = Vector2(1.25, 1)






func _on_TestBlock_body_exited(body):
	if body.is_in_group("Player"):
		$Sprite.play("unpressed")
		$Sprite.scale = $Sprite.scale.linear_interpolate(Vector2(1, 1),1)
