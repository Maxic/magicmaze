extends Spatial
class_name Hero

var x
var y
var vec_pos
var type
var remaining_path
enum phase {WAITING, MOVING, DONE}
var current_phase
var current_pos
var new_pos

var hero_sprite = preload("res://scenes/hero_sprite.tscn")

func _init(x_pos, y_pos):
	self.x = x_pos
	self.y = y_pos
	self.vec_pos = Vector2(x,y)
	
	# Add to correct group
	add_to_group("heroes")
	
	# Move to correct position
	move_to_pos(x, y)
	var sprite = hero_sprite.instance()
	
	# Initialize self in world
	add_child(sprite)

func _physics_process(delta):
	if GameLogic.current_phase == GameLogic.phase.ENEMY_ACTION:
		if current_phase == phase.MOVING:
			if remaining_path:
				move_along_path(remaining_path)
			else:
				self.current_phase = phase.DONE

		
	
func move_to_pos(x_pos, y_pos):
	translation = Vector3(x_pos*2, translation.y, y_pos*2)
	self.x = x_pos
	self.y = y_pos
	self.vec_pos = Vector2(x,y)
	
func move_along_path(path_arr):
		remaining_path = path_arr
		var pos = remaining_path[0]
		new_pos = Vector3(pos.x*2,translation.y,pos.y*2)
		self.translation = lerp(self.translation, new_pos, 0.3)
		if self.translation.x > new_pos.x-0.1 && self.translation.x < new_pos.x + 0.1 && \
		self.translation.z > new_pos.z-0.1 && self.translation.z < new_pos.z + 0.1:
			remaining_path.pop_front()
		
