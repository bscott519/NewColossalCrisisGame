extends Node

var unlocked_lvls: Array[String] = ["res://Scenes/level_1.tscn"]
const save_path := "user://progress.cfg"

func _ready():
	load_prog()

func unlock_lvl(lvl_name: String):
	if not unlocked_lvls.has(lvl_name):
		unlocked_lvls.append(lvl_name)
		save_prog()

func is_lvl_unlocked(lvl_name: String) -> bool:
	return unlocked_lvls.has(lvl_name)

func save_prog():
	var config = ConfigFile.new()
	config.set_value("progress", "unlocked_lvls", unlocked_lvls)
	config.save(save_path)

func load_prog():
	var config = ConfigFile.new()
	var err = config.load(save_path)
	if err == OK:
		unlocked_lvls = config.get_value("progress", "unlocked_lvls", [])
