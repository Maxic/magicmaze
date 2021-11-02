extends Spatial

var red_mat = preload("res://assets/models/move_indicator/move_indicator_red.material")

func set_color_red():
	
	get_children()[0].set_surface_material(0, red_mat)
