extends Node2D

@onready var animation_tree = $AnimationTree

const atk_threshold = 1
const swipes = ["left_swipe", "right_swipe"]

var idle_count = 0
var atk_set = swipes

func _ready():
	randomize()

func increase_idle_count():
	idle_count += 1
	
	if idle_count > atk_threshold:
		idle_count = 0
		attack()

func attack():
	var atk = atk_set
	
