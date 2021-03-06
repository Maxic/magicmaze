extends Node

enum phase {INITIAL, HERO_INTENTION, PLAYER_PHASE, HERO_ACTION}

# config
var grid_dimension
var hero_amount
var max_total_hero_amount
var min_hero_on_grid_amount
var max_hero_on_grid_amount
var treasure_amount
var monster_amount
var turn_amount
var hp

# State vars
var gold
var current_phase
var end_player_phase
var end_hero_action_phase
var end_initial_phase
var dead
var victory
var reset_game
var turn
var spawn_goblin

# Keep track arrays
var hero_array
var treasure_array
var monster_array

# Nodes
onready var main = get_node("/root/main")

#scenes
var hightlight_cube = load("res://scenes/highlight_cube.tscn")
var hightlight_cube_inst

func reset():
	# Reset all our vars
	grid_dimension = 5
	min_hero_on_grid_amount =  2
	max_hero_on_grid_amount = 6
	max_total_hero_amount = 7
	treasure_amount = 2
	monster_amount = 2
	turn_amount = 6
	hp = treasure_amount
	gold = 100 * treasure_amount

	end_player_phase = false
	end_hero_action_phase = false
	end_initial_phase = false
	dead = false
	victory = false
	reset_game = false
	spawn_goblin = false
	turn = turn_amount
	
	hero_array = []
	treasure_array = []
	monster_array = []
	
func _ready():
	# Set all vars
	reset()
	
	# Randomize with specfic seed (found in output)
	get_and_set_seed()
	
	# Reset singletons
	EventManager.reset()
	
	# Create initial grid
	Grid.create_grid(grid_dimension)
	hightlight_cube_inst = hightlight_cube.instance()
	main.add_child(hightlight_cube_inst)
	hightlight_cube_inst.visible = false
	
	
	
	# Populate grid with objects
	spawn_treasures()
	spawn_heroes()
	
	# Start phase loop with hero intention phase
	current_phase = phase.INITIAL
	
func _physics_process(_delta):
#####~~  UNRELATED TO PHASES, ACT IMMEDIATELY ~~#####
	if reset_game:
		_ready()
	get_input()

	check_for_player_death()
	if dead:
		return
	if current_phase != phase.INITIAL:
		check_for_player_victory()
		if victory:
			return
#####~~  INITIAL PHASE, SPAWN TREASURES, PLACE GOBLINS, SPAWN HEROES ~~#####
	if current_phase == phase.INITIAL:
		spawn_goblins()
		EventManager.update_gold_amount()
		if monster_array.size() == monster_amount:
			end_initial_phase = true
		if end_initial_phase:
			show_heroes()
			
			current_phase = phase.HERO_INTENTION
#####~~  FIRST PHASE, CALCULATE AND SHOW HERO INTENTION ~~#####
	if current_phase == phase.HERO_INTENTION:
		# calculate paths, and display intention
		turn -= 1
		EventManager.set_turn_timer(turn)
		for hero in hero_array:
			if hero.current_phase != hero.phase.SPAWNING:
				var paths = Pathfinder.find_shortest_paths(hero.vec_pos, Grid.update_grid().duplicate())
				hero.set_intent_and_path(paths)
				hero.display_path()
				hero.current_phase = hero.phase.WAITING
		# No end condition needed here
		# Just calculate, show paths and move on
		EventManager.player_phase_msg()
		end_player_phase = false
		current_phase = phase.PLAYER_PHASE
		return
			
#####~~  SECOND PHASE, PLAYER MOVEMENT ~~#####
	if current_phase == phase.PLAYER_PHASE:
		# movement is handled in grid code
		if end_player_phase:
			EventManager.hero_action_phase_msg()
			show_heroes()
			
			# Calculate new paths again with new grid
			remove_move_indicator_paths()
			for hero in hero_array:
				#var paths = Pathfinder.find_all_paths(hero.vec_pos, Grid.update_grid()).duplicate()
				#hero.pick_best_path(paths)
				hero.recalculate_best_path()
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
			spawn_heroes()	
			if turn != 1:
				current_phase = phase.HERO_INTENTION
				return
			else:
				victory = true
				EventManager.victory_msg()
			
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
	remove_object_from_tile(treasure, treasure.x, treasure.y)
	var index = treasure_array.find(treasure)
	treasure_array.remove(index)

func remove_hero(hero):
	remove_object_from_tile(hero, hero.x, hero.y)
	var index = hero_array.find(hero)
	hero_array.remove(index)

func remove_monster(monster):
	remove_object_from_tile(monster, monster.x, monster.y)
	var index = monster_array.find(monster)
	monster_array.remove(index)
	
func get_and_set_seed():
	# Can you even win this one? 3585261507
	randomize()
	var seed_int = randi()
	print("Seed: " + str(seed_int))
	#seed(3585261507)
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
		edge_arr.append(Vector2(0,i))
		edge_arr.append(Vector2(grid_dimension-1,i))
		edge_arr.append(Vector2(i,0))
		edge_arr.append(Vector2(i,grid_dimension-1))

	# spawn heroes in the remaining tiles, amount based on config
	var heroes_added = 0
	if hero_array.size() < min_hero_on_grid_amount:
		heroes_added = min_hero_on_grid_amount - hero_array.size()
	elif hero_array.size() <= max_hero_on_grid_amount:
		heroes_added = ((randi() % 2)+1)
	
	print(heroes_added)
	
	max_total_hero_amount -= heroes_added

	if max_total_hero_amount > 0: 
		for i in heroes_added:
			edge_arr.shuffle()
			var hero = Hero.new(edge_arr[0].x,edge_arr[0].y)
			edge_arr.remove(0)
			hero_array.append(hero)
			hero.turn_order = hero_array.find(hero)
			main.add_child(hero)

func show_heroes():
	for hero in hero_array:
		if hero.current_phase == hero.phase.SPAWNING:
			hero.show_hero()
	
func spawn_treasures():
	# Generate array of tiles _not_ on edge of grid
	var inner_arr = []
	for y in range(1, grid_dimension-1):
		for x in range(1, grid_dimension-1):
			inner_arr.append(Vector2(x,y))
	
	# spawn object on tile, and romove tile from array
	inner_arr.shuffle()	
	for i in treasure_amount:
		var treasure = Treasure.new(inner_arr[0].x,inner_arr[0].y)
		inner_arr.remove(0)
		treasure_array.append(treasure)
		main.add_child(treasure)

func spawn_goblins():
	if spawn_goblin:
		if Grid.highlighted_tile != null:
			var monster = Monster.new(Grid.highlighted_tile.x,Grid.highlighted_tile.y, "goblin")
			monster_array.append(monster)
			main.add_child(monster)
	spawn_goblin = false

func get_input():
	if Input.is_action_just_pressed("mouse_1"):
		spawn_goblin = true
	if Input.is_action_just_pressed("reset"):
		Grid.reset()
		var _result = get_tree().reload_current_scene()
		reset_game = true

func highlight_tile(pos):
	if current_phase == phase.INITIAL:
		if pos.y >= 0 and pos.y < Grid.GRID_DIMENSION and \
			pos.x >= 0 and pos.x < Grid.GRID_DIMENSION:
			var tile = Grid.grid[pos.y][pos.x]
			if Grid.highlighted_tile != tile:
				if Grid.highlighted_tile:
					hightlight_cube_inst.visible = true
					hightlight_cube_inst.translation = Vector3(pos.x*2,1,pos.y*2)
				Grid.highlighted_tile = tile
		elif not Grid.highlighted_tile == null:
			hightlight_cube_inst.visible = false
			Grid.highlighted_tile = null		
	else:
		if not Grid.highlighted_tile == null:
			hightlight_cube_inst.visible = false
			Grid.highlighted_tile = null	
