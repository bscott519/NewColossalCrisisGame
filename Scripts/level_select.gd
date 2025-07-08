extends Control
class_name LevelSelect

@onready var cur_lvl: LevelIcon = $LevelIcon

# Called when the node enters the scene tree for the first time.
func _ready():
	LevelManager.load_prog()
	
	$TitleTheme.play()
	$TitleTheme.finished.connect(_on_title_theme_finished)
	$PlayerIcon.global_position = cur_lvl.global_position
	
	for icon in get_tree().get_nodes_in_group("level_icons"):
		var is_unlocked = icon.next_scene_path in LevelManager.unlocked_lvls
		icon.set_locked(!is_unlocked)

func _input(event):
	if event.is_action_pressed("left") and cur_lvl.next_level_left:
		cur_lvl = cur_lvl.next_level_left
		$PlayerIcon.global_position = cur_lvl.global_position
	if event.is_action_pressed("right") and cur_lvl.next_level_right:
		cur_lvl = cur_lvl.next_level_right
		$PlayerIcon.global_position = cur_lvl.global_position
	
	if event.is_action_pressed("enter") and !cur_lvl.locked:
		if cur_lvl.next_scene_path and cur_lvl.next_scene_path in LevelManager.unlocked_lvls:
			get_tree().change_scene_to_file(cur_lvl.next_scene_path)
		else:
			print("level is locked")
	
	

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_title_theme_finished():
	$TitleTheme.play()
