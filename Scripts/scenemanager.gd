extends Node

var scenes: Dictionary = { "Level 1": "res://Scenes/level_1.tscn", 
							"Level 2": "res://Scenes/level_2.tscn",
							"Level 3": "res://Scenes/level_3.tscn",
							"Level 4": "res://Scenes/level_4.tscn",
							"Level 5": "res://Scenes/level_5.tscn" }
							
var last_played_scene: String = ""

func set_last_scene(scene_path: String):
	last_played_scene = scene_path

func transition_to_scene(level : String):
	var scene_path : String = scenes.get(level)
	
	if scene_path != null:
		#var scene_transition_screen_instance = scene_transition_screen.instantiate()
		#get_tree().get_root().add_child(scene_transition_screen_instance)
		#await get_tree().create_timer(5.0).timeout
		if get_tree().current_scene:
			last_played_scene = get_tree().current_scene.scene_file_path
		
		get_tree().change_scene_to_file(scene_path)
		#scene_transition_screen_instance.queue_free()
