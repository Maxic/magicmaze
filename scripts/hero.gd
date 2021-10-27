extends Spatial
class_name Hero

var x
var y
var type


func _ready():
	move_to_pos(1,1)
	set_goal(7,7)


func move_to_pos(x_pos, y_pos):
	translation = Vector3(x_pos*2, translation.y, y_pos*2)
	self.x = x_pos
	self.y = y_pos

func set_goal(x_pos, y_pos):
	var goal_x = x_pos
	
func set_intention():
	pass
	#var goal_y = y_pos

