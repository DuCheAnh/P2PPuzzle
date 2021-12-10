extends Area2D

export (float) var multiplier = 1

onready var tween = $Tween
onready var sprite = $Sprite
func _on_TestBlock_body_entered(body):
	if body.is_in_group("Player"):
		sprite.play("pressed")
		sprite.scale = Vector2(1.15, 1)

func _on_TestBlock_body_exited(body):
	if body.is_in_group("Player"):
		sprite.play("unpressed")
		tween.interpolate_property(sprite,"scale", sprite.scale, Vector2(1,1), 0.5,
									Tween.TRANS_BOUNCE, Tween.EASE_OUT)
		tween.start()
