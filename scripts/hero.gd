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
var best_path

var hero_sprite = preload("res://scenes/hero_sprite.tscn")

func _init(x_pos, y_pos):
	# Move to correct position and set position params
	self.x = x_pos
	self.y = y_pos
	self.vec_pos = Vector2(x,y)
	move_to_pos(x_pos, y_pos)
		
	# Add to correct group
	add_to_group("heroes")
	
	# Initialize self in world
	var sprite = hero_sprite.instance()
	add_child(sprite)


func _physics_process(delta):
	if GameLogic.current_phase == GameLogic.phase.ENEMY_ACTION:
		if current_phase == phase.MOVING:
			if remaining_path:
				move_along_path(remaining_path)
			else:
				self.current_phase = phase.DONE
				
				
func move_to_pos(x_pos, y_pos):
	GameLogic.remove_object_from_tile(self,x,y)
	translation = Vector3(x_pos*2, translation.y, y_pos*2)
	self.x = x_pos
	self.y = y_pos
	self.vec_pos = Vector2(x,y)
	GameLogic.add_object_to_tile(self,x,y)
	
	
func move_along_path(path_arr):
		remaining_path = path_arr
		var pos = remaining_path[0]
		new_pos = Vector3(pos.x*2,translation.y,pos.y*2)
		self.translation = lerp(self.translation, new_pos, 0.3)
		if self.translation.x > new_pos.x-0.1 && self.translation.x < new_pos.x + 0.1 && \
		self.translation.z > new_pos.z-0.1 && self.translation.z < new_pos.z + 0.1:
			move_to_pos(pos.x,pos.y)
			remaining_path.pop_front()
	
func pick_best_path(paths):
	var best_path = find_best_treasure_path(paths)
	
	self.remaining_path = best_path
		
func find_all_treasure_paths(paths):
	var treasure_paths = []
	var treasure_pos_arr = []
	for treasure in GameLogic.treasure_array:
		treasure_pos_arr.append(treasure.vec_pos)
	for path in paths:
		for pos in path:
			var obtainable_treasure_index = treasure_pos_arr.find(pos)
			if obtainable_treasure_index >= 0:
				var end_path_index = path.find(treasure_pos_arr[obtainable_treasure_index])
				for i in range(end_path_index+1, path.size()):
					path.remove(end_path_index+1)
				treasure_paths.append(path)
	return treasure_paths

	
func find_best_treasure_path(paths):
	var treasure_paths = find_all_treasure_paths(paths)
	var shortest_path_size = Grid.GRID_DIMENSION * Grid.GRID_DIMENSION
	if treasure_paths:
		for path in treasure_paths:
			if path.size() < shortest_path_size:
				best_path = path	
				shortest_path_size = path.size()
		return best_path
	else:
		return paths[0]
		
				
			
	
