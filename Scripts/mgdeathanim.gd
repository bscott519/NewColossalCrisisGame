extends Node2D

@onready var mg_death_sprite = $MGDeath

func _ready():
	mg_death_sprite.play("death")
	mg_death_sprite.connect("animation_finished", _on_anim_finished)

func _on_anim_finished():
	queue_free()
