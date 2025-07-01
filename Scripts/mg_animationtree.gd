extends AnimationTree

func set_condition(condtition_name, value):
	set("parameters/conditions/" + condtition_name, value)
