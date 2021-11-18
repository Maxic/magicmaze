extends Spatial
class_name Hero
const CLASS_NAME = "Hero"

var x
var y
var vec_pos
var type
var remaining_path : Array
enum phase {WAITING, MOVING, DONE, SPAWNING}
var current_phase
enum intent {WANDERING, PILLAGING, ATTACKING}
var current_intent
var current_pos
var new_pos
var turn_order
var sprite

var hero_model = preload("res://scenes/hero_model.tscn")
var move_indicator_scene = preload("res://scenes/move_indicator.tscn")
var move_indicator_static_scene = preload("res://scenes/move_indicator_static.tscn")
var hero_stats = preload("res://scenes/hero_stats.tscn")
var spawn_indicator_scene = preload("res://scenes/spawn_indicator.tscn")

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
	var sprite = hero_model.instance()
	sprite.visible = false
	add_child(sprite)
	GameLogic.add_object_to_tile(self, x, y)
	
	# When just spawned, show indicator, but not hero itself

	var spawn_indicator = spawn_indicator_scene.instance()
	spawn_indicator.name = "spawn_indicator"
	add_child(spawn_indicator)
	current_phase = phase.SPAWNING
	
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
	var tile = Grid.grid[y][x]
	# If there is a treasure on the tile
	# Pick it up
	var treasure = tile.get_treasure()
	if treasure and current_intent == intent.PILLAGING:
		treasure.picked_up()
	# If there is a treasure on the tile
	# Kill it when attacking, otherwise, die.
	var monster = tile.get_monster()
	if monster:
		if current_intent == intent.ATTACKING:
			monster.die()
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
	if paths.has("treasure"):
		self.remaining_path = paths["treasure"]
		self.current_intent = intent.PILLAGING
		# If there is a monster in the path, 
		# attack that monster instead of going for the treasure
		if paths.has("monster"):
			for step in self.remaining_path:
				if Grid.grid[step.y][step.x].get_monster():
					self.current_intent = intent.ATTACKING
					var monster_index = self.remaining_path.find(step)
					self.remaining_path = self.remaining_path.slice(0, monster_index)
		
	elif paths.has("monster"):
		self.remaining_path = paths["monster"]
		self.current_intent = intent.ATTACKING
	else:
		self.remaining_path = paths["random"]
		self.current_intent = intent.WANDERING
	
func recalculate_best_path():
	var possible_path = []
	
	if remaining_path == []:
		return
	#if moved, cancel path
	if x != remaining_path[0].x || y != remaining_path[0].y:
		remaining_path = []
	else:
		possible_path.append(remaining_path[0])
			
	for step_i in remaining_path.size()-1:
		var current_step = remaining_path[step_i]
		var next_step = remaining_path[step_i+1]
		if Pathfinder.tiles_are_connected(current_step, next_step, Grid.update_grid()):
			possible_path.append(remaining_path[step_i+1])
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

func show_hero():
	$hero.visible = true
	current_phase = phase.WAITING
	$spawn_indicator.queue_free()
	

func die():
	GameLogic.remove_hero(self)
	queue_free()

func get_class(): return CLASS_NAME
