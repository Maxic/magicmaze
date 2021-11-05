extends Spatial
class_name Hero
const CLASS_NAME = "Hero"

var x
var y
var vec_pos
var type
var remaining_path
enum phase {WAITING, MOVING, DONE}
var current_phase
enum intent {NOTHING, PICK_UP, ATTACKING}
var current_intent
var current_pos
var new_pos
var turn_order

var hero_sprite = preload("res://scenes/hero_sprite.tscn")
var move_indicator_scene = preload("res://scenes/move_indicator.tscn")
var move_indicator_static_scene = preload("res://scenes/move_indicator_static.tscn")
var hero_stats = preload("res://scenes/hero_stats.tscn")

func _init(x_pos, y_pos):
	# Move to correct position and set position params
	self.x = x_pos
	self.y = y_pos
	self.vec_pos = Vector2(x,y)
	update_pos(x_pos, y_pos)
		
	# Add to correct group
	name = "hero"
	add_to_group("heroes")
	
	# Initialize self in world
	var sprite = hero_sprite.instance()
	add_child(sprite)
	GameLogic.add_object_to_tile(self, x, y)
	
	var hero_stats_inst = hero_stats.instance()
	add_child(hero_stats_inst)

func _physics_process(_delta):
	if GameLogic.current_phase == GameLogic.phase.HERO_ACTION:
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
	check_for_objects()
	
func check_for_objects():
	for object in Grid.grid[y][x].objects:
		var object_class = object.get_class()
		if object_class == "Treasure":
			object.picked_up()
		if object_class == "Monster":
			if current_intent == intent.ATTACKING:
				object.die()
			else:
				die()
	
func update_pos(x_pos, y_pos):
	translation = Vector3(x_pos*2, translation.y, y_pos*2)
	self.x = x_pos
	self.y = y_pos
	self.vec_pos = Vector2(x,y)
	
func move_along_path(path_arr):
		remaining_path = path_arr
		var pos = remaining_path[0]
		new_pos = Vector3(pos.x*2,translation.y,pos.y*2)
		self.translation = lerp(self.translation, new_pos, 0.1)
		if self.translation.x > new_pos.x-0.1 && self.translation.x < new_pos.x + 0.1 && \
		self.translation.z > new_pos.z-0.1 && self.translation.z < new_pos.z + 0.1:
			move_to_pos(pos.x,pos.y)
			remaining_path.pop_front()
	
func set_intent_and_path(paths):
	# TODO: Fix bug here, 
	# if the order between monster and treasure is swapped, it does not work
	if paths.has("monster"):
		self.remaining_path = paths["monster"]
		self.current_intent = intent.ATTACKING
	elif paths.has("treasure"):
		self.remaining_path = paths["treasure"]
		self.current_intent = intent.PICK_UP
	else:
		self.remaining_path = [Vector2(self.x, self.y)]
		self.current_intent = intent.NOTHING
	
func recalculate_best_path(paths):
	var possible_path = []
	var step_index = 0
	var step_possible
	
	for _index in range(remaining_path.size()):
		step_possible = false
		for i in range(paths.size()):
			if step_index < paths[i].size() &&  step_index < remaining_path.size() && \
			  paths[i][step_index] == remaining_path[step_index]:
				step_possible = true
		if step_possible:
			possible_path.append(remaining_path[step_index])
			step_index += 1
		else:
			remaining_path = possible_path.duplicate()
			return
	
func display_path():
	if remaining_path:
		for i in remaining_path.size():
			var move_indicator
			if i != remaining_path.size()-1:	
				move_indicator = move_indicator_scene.instance()
				move_indicator.translation.y = -.2
				# west
				if remaining_path[i].x < remaining_path[i+1].x:
					move_indicator.rotation_degrees.y = 270
				# east
				elif remaining_path[i].x > remaining_path[i+1].x:
					move_indicator.rotation_degrees.y = 90
				# south
				elif remaining_path[i].y < remaining_path[i+1].y:
					move_indicator.rotation_degrees.y = 180
			else:
				move_indicator = move_indicator_static_scene.instance()
				move_indicator.scale *= .7
			move_indicator.translation.x = remaining_path[i].x*2
			move_indicator.translation.z = remaining_path[i].y*2

			if current_intent == intent.ATTACKING:
				move_indicator.set_color_red()
			move_indicator.add_to_group("move_indicators")
			get_parent().add_child(move_indicator)

func die():
	var objects = Grid.grid[y][x].objects
	for object in objects:
		if object.get_class() == CLASS_NAME:
			Grid.grid[y][x].remove_object(object)
	GameLogic.remove_hero(self)
	queue_free()

func get_class(): return CLASS_NAME
