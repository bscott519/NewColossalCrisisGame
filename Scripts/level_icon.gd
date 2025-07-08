@tool
extends Control
class_name LevelIcon

@export var lvl_name := "1"
@export_file("*.tscn") var next_scene_path: String
@export var next_level_left: LevelIcon
@export var next_level_right: LevelIcon

var locked := true  

@onready var texture_rect = $TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = "Level " + str(lvl_name)

func set_locked(is_locked: bool):
	locked = is_locked
	modulate = Color(1, 1, 1, 0.4) if locked else Color(1, 1, 1, 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint():
		$Label.text = "Level " + str(lvl_name)
