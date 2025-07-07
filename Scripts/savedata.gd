extends Node

const save_path = "user://save_data.save"
var unlocked_lvls: Array[bool] = [true, false, false, false, false, false, false]

func _ready():
	load_data()

func unlock_lvl(index: int):
	if index < unlocked_lvls.size():
		unlocked_lvls[index] = true
		save_data()

func is_unlocked(index: int) -> bool:
	return unlocked_lvls[index]

func save_data():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(unlocked_lvls)

func load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		unlocked_lvls = file.get_var()
