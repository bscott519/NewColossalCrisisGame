extends Node2D

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree["parameters/playback"]

const atk_threshold = 2
const swipes = ["left_swipe", "right_swipe", "laser_eyes", "left_blast", "right_blast"]

var idle_count = 0
var atk_set = swipes

func _ready():
	randomize()
	animation_tree.active = true

func _on_animation_player_animation_finished(idle):
	if idle == "idle":
		increase_idle_count()

func increase_idle_count():
	idle_count += 1
	
	if idle_count > atk_threshold:
		idle_count = 0
		attack()

func attack():
	var atk = atk_set[randi() % atk_set.size()]
	
	for attack in atk_set:
		animation_tree.set("parameters/conditions/%s" % attack, false)
	animation_tree.set("parameters/conditions/%s" % atk, true)
