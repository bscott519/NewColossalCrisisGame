extends Node

@export var next_scene : String
@export var next_lvl_name: String
var scene_transitioning: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_exit_area_2d_body_entered(body):
	if body.is_in_group("player"):
		scene_transitioning = true
		
		var player = body
		player.queue_free()
		
		LevelManager.unlock_lvl(next_scene)
		get_tree().change_scene_to_file("res://Scenes/level_cleared.tscn")
		#await get_tree().create_timer(0.5).timeout
		#Scenemanager.transition_to_scene(next_scene)
