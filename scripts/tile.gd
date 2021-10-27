extends Spatial
class_name Tile

var x
var y
var type

var cross_n_e_s_w = preload("res://scenes/cross_n_e_s_w.tscn")
var straight_n_s = preload("res://scenes/straight_n_s.tscn")
var straight_e_w = preload("res://scenes/straight_e_w.tscn")
var corner_n_w = preload("res://scenes/corner_n_w.tscn")
var corner_n_e = preload("res://scenes/corner_n_e.tscn")
var corner_s_w = preload("res://scenes/corner_s_w.tscn")
var corner_s_e = preload("res://scenes/corner_s_e.tscn")
var t_n_e_s = preload("res://scenes/t_n_e_s.tscn")
var t_n_e_w = preload("res://scenes/t_n_e_w.tscn")
var t_n_w_s = preload("res://scenes/t_n_w_s.tscn")
var t_s_e_w = preload("res://scenes/t_s_w_e.tscn")
var def_block = preload("res://scenes/default_cube.tscn")

func _init(x_pos, y_pos, path_type):
	self.x = x_pos
	self.y = y_pos
	self.type = get_type(path_type)
	self.scale = Vector3(.97,.97,.97)
	
	# Add to correct group
	add_to_group("tiles")
	
	# Move to correct position
	move_to_pos(x, y)
	var mesh = self.type.instance()
	
	# Initialize self in world
	add_child(mesh)
	
func move_to_pos(x_pos, y_pos):
	translation = Vector3(x_pos*2, 0, y_pos*2)
	self.x = x_pos
	self.y = y_pos

func get_type(path_type):
	match path_type:
		"cross_n_e_s_w":
			return cross_n_e_s_w
		"straight_n_s":
			return straight_n_s
		"straight_e_w":
			return straight_e_w
		"corner_n_w":
			return corner_n_w
		"corner_n_e":
			return corner_n_e
		"corner_s_w":
			return corner_s_w
		"corner_s_e":
			return corner_s_e
		"t_n_e_s":
			return t_n_e_s
		"t_n_e_w":
			return t_n_e_w
		"t_n_w_s":
			return t_n_w_s
		"t_s_e_w":
			return t_s_e_w
		_:
			return def_block
