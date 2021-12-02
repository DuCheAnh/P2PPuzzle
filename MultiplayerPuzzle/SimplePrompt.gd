extends Control


func set_text(new_text) -> void:
	$Panel/Label.text = new_text

func _on_OkButton_pressed():
	get_tree().change_scene("res://NetworkSetup.tscn")
