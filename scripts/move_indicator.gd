extends Spatial

var red_mat = preload("res://assets/models/move_indicator/move_indicator_red.material")
var green_mat = preload("res://assets/models/move_indicator/move_indicator_green.material")

func set_color_red():
	
	get_children()[0].set_surface_material(0, red_mat)

func set_color_green():
	
	get_children()[0].set_surface_material(0, green_mat)
