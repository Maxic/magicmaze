extends Spatial
class_name Hero

var x
var y
var i = 0
var type
var remaining_path
var hero_move = false
var current_pos
var new_pos

func _ready():
	jump_to_pos(0,0)


func _physics_process(delta):
	
	if hero_move:
		self.translation = lerp(self.translation, new_pos, 0.03)
		if self.translation.x > new_pos.x-0.1 && self.translation.x <= new_pos.x && \
		   self.translation.z > new_pos.z-0.1 && self.translation.z <= new_pos.z:
			if remaining_path:
				move_to_pos(remaining_path)
			else:
				hero_move = false
			

func jump_to_pos(x_pos, y_pos):
	translation = Vector3(x_pos*2, translation.y, y_pos*2)
	self.x = x_pos
	self.y = y_pos


func move_to_pos(path_arr):
		remaining_path = path_arr
		var pos = remaining_path[0]
		new_pos = Vector3(pos.x*2,translation.y,pos.y*2)
		remaining_path.pop_front()
		hero_move = true;
	
			
