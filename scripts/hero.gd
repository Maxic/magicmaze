extends Spatial
class_name Hero

var x
var y
var vec_pos
var i = 0
var type
var remaining_path
var hero_move = false
var current_pos
var new_pos

var hero_mesh = preload("res://scenes/hero_mesh.tscn")

func _init(x_pos, y_pos):
	self.x = x_pos
	self.y = y_pos
	self.vec_pos = Vector2(x,y)
	
	# Add to correct group
	add_to_group("heroes")
	
	# Move to correct position
	move_to_pos(x, y)
	var mesh = hero_mesh.instance()
	
	# Initialize self in world
	add_child(mesh)

func _physics_process(delta):
	if hero_move:
		self.translation = lerp(self.translation, new_pos, 0.03)
		if self.translation.x > new_pos.x-0.1 && self.translation.x < new_pos.x + 0.1 && \
		   self.translation.z > new_pos.z-0.1 && self.translation.z < new_pos.z + 0.1:
			if remaining_path:
				move_along_path(remaining_path)
			else:
				hero_move = false
	
	
func move_to_pos(x_pos, y_pos):
	translation = Vector3(x_pos*2, translation.y, y_pos*2)
	self.x = x_pos
	self.y = y_pos
	
	
func move_along_path(path_arr):
		remaining_path = path_arr
		var pos = remaining_path[0]
		new_pos = Vector3(pos.x*2,translation.y,pos.y*2)
		remaining_path.pop_front()
		hero_move = true;
