extends Label

export (float) var fade_duration = 2

onready var tween = $Tween
func set_message(message):
	text = message

	tween.interpolate_property(self,"modulate",Color(1,1,1,1),Color(1,1,1,0),fade_duration,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	tween.start()

func _on_Tween_tween_all_completed():
	queue_free()

