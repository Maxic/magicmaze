extends Node

enum phase {ENEMY_INTENTION, PLAYER_PHASE, ENEMY_ACTION}

# State vars
var current_phase
var end_player_phase = false
var end_enemy_action_phase = false
var hero_amount = 3
var treasure_amount = 2
var hero_array = []
var treasure_array = []

# Nodes
onready var main = get_node("/root/main")


func _ready():
	Grid.create_grid()
	
	for i in hero_amount:
		i = Hero.new(randi() % Grid.GRID_DIMENSION,randi() % Grid.GRID_DIMENSION)
		hero_array.append(i)
		main.add_child(i)
	
	for i in treasure_amount:
		i = Treasure.new(randi() % Grid.GRID_DIMENSION, randi() % Grid.GRID_DIMENSION)
		treasure_array.append(i)
		main.add_child(i)
	
	current_phase = phase.ENEMY_INTENTION
	
func _physics_process(delta):

	if current_phase == phase.ENEMY_INTENTION:
		if true: # Skip tis for now
			end_player_phase = false
			current_phase = phase.PLAYER_PHASE
			return
	if current_phase == phase.PLAYER_PHASE:
		if end_player_phase:
			# setup next phase
			for hero in hero_array:
				var paths = Pathfinder.find_all_paths(hero.vec_pos, Grid.grid)
				hero.pick_best_path(paths)
				hero.current_phase = hero.phase.WAITING
			
			end_enemy_action_phase = false	
			current_phase = phase.ENEMY_ACTION
			return
	if current_phase == phase.ENEMY_ACTION:
		for i in range(hero_array.size()):
			var hero = hero_array[i]
			if hero.current_phase == hero.phase.WAITING:
				if i > 0 && hero_array[i-1].current_phase == hero.phase.DONE:
					hero.current_phase = hero.phase.MOVING
				elif i == 0:
					hero.current_phase = hero.phase.MOVING
			if hero.current_phase == hero.phase.DONE && i == hero_array.size()-1:
				end_enemy_action_phase = true
		if end_enemy_action_phase:
			current_phase = phase.ENEMY_INTENTION
			return
			
func remove_object_from_tile(object,object_x,object_y):
	var tile = Grid.grid[object_y][object_x]
	tile.remove_object(object)
		
		
func add_object_to_tile(object,object_x,object_y):
	var tile = Grid.grid[object_y][object_x]
	tile.add_object(object)
	

