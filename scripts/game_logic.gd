extends Node

enum phase {HERO_INTENTION, PLAYER_PHASE, HERO_ACTION}

# config
var grid_dimension = 7
var hero_amount = 2
var treasure_amount = 2
var monster_amount = 2
var hp = 1

# State vars
var current_phase
var end_player_phase = false
var end_hero_action_phase = false
var dead = false
var victory = false

# Keep track arrays
var hero_array = []
var treasure_array = []
var monster_array = []

# Nodes
onready var main = get_node("/root/main")

func _ready():
	# Randomize with specfic seed (found in output)
	get_and_set_seed()
	
	# Create initial grid
	Grid.create_grid(grid_dimension)
	
	# Populate grid with objects
	spawn_heroes()
	spawn_maze_objects()
	
	# Start phase loop with hero intention phase
	current_phase = phase.HERO_INTENTION
	
func _physics_process(_delta):
#####~~  UNRELATED TO PHASES, ACT IMMEDIATELY ~~#####
	check_for_player_death()
	if dead:
		return
	check_for_player_victory()
	if victory:
		return

#####~~  FIRST PHASE, CALCULATE AND SHOW HERO INTENTION ~~#####
	if current_phase == phase.HERO_INTENTION:
		# calculate paths, and display intention
		for hero in hero_array:
			var paths = Pathfinder.find_all_paths(hero.vec_pos, Grid.update_grid().duplicate())
			hero.pick_best_path(paths)
			hero.display_path()
			hero.current_phase = hero.phase.WAITING
		# No end condition needed here
		# Just calculate, show paths and move on
		end_player_phase = false
		current_phase = phase.PLAYER_PHASE
		return
			
#####~~  SECOND PHASE, PLAYER MOVEMENT ~~#####
	if current_phase == phase.PLAYER_PHASE:
		# movement is handled in grid code
		if end_player_phase:
			# Calculate new paths again with new grid
			remove_move_indicator_paths()
			for hero in hero_array:
				var paths = Pathfinder.find_all_paths(hero.vec_pos, Grid.update_grid()).duplicate()
				#hero.pick_best_path(paths)
				hero.recalculate_best_path(paths)
				hero.display_path()
			end_hero_action_phase = false
			current_phase = phase.HERO_ACTION
			return
			
#####~~  THIRD PHASE, ENEMY ACTION ~~#####	
	if current_phase == phase.HERO_ACTION:
		# If there are no heroes, stop this phase.
		if !hero_array:
			end_hero_action_phase = true
		# For each hero, do movement one at a time
		for i in range(hero_array.size()):
			var hero = hero_array[i]
			if hero.current_phase == hero.phase.WAITING:
				if i > 0 && hero_array[i-1].current_phase == hero.phase.DONE:
					hero.current_phase = hero.phase.MOVING
				elif i == 0:
					hero.current_phase = hero.phase.MOVING
			# If the last hero is done, move on to the next phase
			if hero.current_phase == hero.phase.DONE && i == hero_array.size()-1:
				end_hero_action_phase = true
		# Phase is over, setup stuff for next phase
		if end_hero_action_phase:
			remove_move_indicator_paths()
			current_phase = phase.HERO_INTENTION
			return
			
func remove_object_from_tile(object,object_x,object_y):
	var tile = Grid.grid[object_y][object_x]
	tile.remove_object(object)
		
func add_object_to_tile(object,object_x,object_y):
	var tile = Grid.grid[object_y][object_x]
	tile.add_object(object)
	
func remove_move_indicator_paths():
	for move_indicator in get_tree().get_nodes_in_group("move_indicators"):
		move_indicator.queue_free()

func remove_treasure(treasure):
	var index = treasure_array.find(treasure)
	treasure_array.remove(index)

func remove_hero(hero):
	var index = hero_array.find(hero)
	hero_array.remove(index)
	
func get_and_set_seed():
	# Long path, treasures not on path: 4029905039
	# fun get 3 treasures: 2486799252
	# Both Heroes die on a single goblin: 183702472 (5 tiles, 2 heroes 2 goblins)
	# Buggy seed: 2080584425 (7tiles, 2 heroes, 2 goblins, 2 treasures) FIXED
	randomize()
	var rng = RandomNumberGenerator.new()
	var seed_int = randi()
	print("Seed: " + str(seed_int))
	seed(2080584425)
	seed(seed_int)

func check_for_player_death():
	if hp == 0 and not dead:
		EventManager.your_are_dead_msg()
		dead = true

func check_for_player_victory():
	if hero_array.size() == 0 and not victory:
		EventManager.victory_msg()
		victory = true

func spawn_heroes():
	# Generate array of tiles on the edge of the grid
	var edge_arr = []
	for i in range(grid_dimension):
		# TODO: Check if tiles have an entrance toward the edge
		edge_arr.append(Vector2(0,i))
		edge_arr.append(Vector2(grid_dimension-1,i))
		edge_arr.append(Vector2(i,0))
		edge_arr.append(Vector2(i,grid_dimension-1))

	# spawn hero in one the remaining tiles
	for i in hero_amount:
		edge_arr.shuffle()
		var hero = Hero.new(edge_arr[0].x,edge_arr[0].y)
		edge_arr.remove(0)
		hero_array.append(hero)
		main.add_child(hero)
	
func spawn_maze_objects():
	# Generate array of tiles _not_ on edge of grid
	var inner_arr = []
	for y in range(1, grid_dimension-1):
		for x in range(1, grid_dimension-1):
			inner_arr.append(Vector2(x,y))
		
	# for treasures and monsters
	# spawn object on tile, and romove tile from array
	inner_arr.shuffle()	
	for i in monster_amount:
		var monster = Monster.new(inner_arr[0].x,inner_arr[0].y, "goblin")
		inner_arr.remove(0)
		monster_array.append(monster)
		main.add_child(monster)
	for i in treasure_amount:
		var treasure = Treasure.new(inner_arr[0].x,inner_arr[0].y)
		inner_arr.remove(0)
		treasure_array.append(treasure)
		main.add_child(treasure)

