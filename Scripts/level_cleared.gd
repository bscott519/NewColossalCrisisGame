extends CanvasLayer

func _on_level_select_pressed():
	get_tree().change_scene_to_file("res://Scenes/level_select.tscn")

func _on_quit_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
