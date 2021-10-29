extends Spatial
class_name Tile

var x
var y
var vec_pos
var type
var facing
var north_open = false
var east_open = false
var west_open = false
var south_open = false
var objects = []

var cross = preload("res://scenes/cross.tscn")
var straight = preload("res://scenes/straight.tscn")
var corner = preload("res://scenes/corner.tscn")
var t_path = preload("res://scenes/t_path.tscn")
var def_block = preload("res://scenes/default_cube.tscn")
var indicator = preload("res://scenes/indicator.tscn")

func _init(x_pos, y_pos, path_type):
	self.x = x_pos
	self.y = y_pos
	self.vec_pos = Vector2(x,y)
	self.type = set_type(path_type)
	self.scale = Vector3(.97,.97,.97)
	self.facing = 0
	
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
	self.vec_pos = Vector2(x_pos, y_pos)

func set_type(path_type):
	match path_type:
		"cross":
			north_open = true
			east_open = true
			west_open = true
			south_open = true
			return cross
		"straight":
			north_open = true
			south_open = true
			return straight
		"corner":
			north_open = true
			east_open = true
			return corner
		"t_path":
			north_open = true
			east_open = true
			south_open = true
			return t_path
		_:
			return def_block

func rotate_clockwise():
	match self.type:
		cross:
			pass
		straight:
			if facing == 0:
				reset_openings()
				east_open = true
				west_open = true
				self.rotation_degrees.y = -90
				facing = 1
				return
			else:
				reset_openings()
				north_open = true
				south_open = true
				self.rotation_degrees.y = 0
				facing = 0
				return
		corner:
			if facing == 0:
				reset_openings()
				east_open = true
				south_open = true
				self.rotation_degrees.y = -90
				facing = 1
				return
			if facing == 1:
				reset_openings()
				south_open = true
				west_open = true
				self.rotation_degrees.y = -180
				facing = 2
				return
			if facing == 2:
				reset_openings()
				west_open = true
				north_open = true
				self.rotation_degrees.y = -270
				facing = 3
				return
			if facing == 3:
				reset_openings()
				north_open = true
				east_open = true
				self.rotation_degrees.y = 0
				facing = 0
				return
		t_path:
			if facing == 0:
				reset_openings()
				east_open = true
				south_open = true
				west_open = true
				self.rotation_degrees.y = -90
				facing = 1
				return
			if facing == 1:
				reset_openings()
				south_open = true
				west_open = true
				north_open = true
				self.rotation_degrees.y = -180
				facing = 2
				return
			if facing == 2:
				reset_openings()
				west_open = true
				north_open = true
				east_open = true
				self.rotation_degrees.y = -270
				facing = 3
				return
			if facing == 3:
				reset_openings()
				north_open = true
				east_open = true
				south_open = true
				self.rotation_degrees.y = 0
				facing = 0
				return

func reset_openings():
	north_open = false
	east_open = false
	south_open = false
	west_open = false

func remove_object(object):
	var object_index = objects.find(object)
	if object_index != -1:
		objects.remove(object_index)
		#remove_indicator()

func add_object(object):
	objects.append(object)
	#set_indicator()
	
func update_object_positions():
	if objects:
		for object in objects:
			object.update_pos(x, y)

#func set_indicator():
#	var indicator_inst = indicator.instance()
#	indicator_inst.name = "indicator"
#	add_child(indicator_inst)
#
#func remove_indicator():
#	if $indicator:
#		$indicator.queue_free()

