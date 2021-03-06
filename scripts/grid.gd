extends Node

# Grid must be square
var GRID_DIMENSION 
var GRID_HEIGHT = GRID_DIMENSION
var GRID_WIDTH = GRID_DIMENSION

# A grid state consists of the grid and the indicator tile
var grid = []
var indicator_tile

# We keep track of past grid states by saving hem in this array
var grid_states = []

# These are the types of tiles the grid consists of, in various rotations
var type_arr = [
	"cross", 
	"straight", 
	"corner", 
	"t_path"
	]

# variables for the random distribution of tiles
var total_weight
var types_dict = {}

var static_pos_arr = []
var indicator_index = 0
var highlighted_tile = null


func reset():
	for tile in get_tree().get_nodes_in_group("tiles"):
		tile.queue_free()
	indicator_index = 0
	highlighted_tile = null

func create_grid(dimension):
	GRID_DIMENSION = dimension
	GRID_HEIGHT = GRID_DIMENSION
	GRID_WIDTH = GRID_DIMENSION
	
	# Initialize grid with 0's
	initialize_grid()
	
	# Initialize types dictionary
	types_dict["cross"] = 		[0.5, 0.0]
	types_dict["straight"] = 	[0.2, 0.0]
	types_dict["corner"] = 		[0.0, 0.0]
	types_dict["t_path"] = 		[0.2, 0.0]
	init_probabilities(types_dict)
	
	# Fill grid with actual tiles
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var tile = Tile.new(x,y, pick_some_object(types_dict))
			# apply random rotation to tiles
			for i in randi()%4:
				tile.rotate_clockwise()
			add_child(tile)
			grid[y][x] = tile
	
	# Create static position array for indicator block
	static_pos_arr = create_indicator_pos_arr()
	
	# Place indicator cube
	var indicator_pos = static_pos_arr[indicator_index]
	type_arr.shuffle()
	indicator_tile = Tile.new(indicator_pos.x, indicator_pos.y, type_arr[0])
	add_child(indicator_tile)
	
	grid_states.append([grid, indicator_tile])

func initialize_grid():
	grid = []
	for y in range(GRID_HEIGHT):
		grid.append([])
		for _x in range(GRID_WIDTH):
			grid[y].append(0)

func _physics_process(_delta):
	if GameLogic.current_phase == GameLogic.phase.PLAYER_PHASE:
		if Input.is_action_just_pressed("accept_indicator"):
			if indicator_tile.x == -1 || indicator_tile.x == GRID_WIDTH:
				move_row_horizontal(indicator_tile.y, indicator_tile.x == -1)
			if indicator_tile.y == -1 || indicator_tile.y == GRID_HEIGHT:
				move_row_vertical(indicator_tile.x, indicator_tile.y == GRID_HEIGHT)
			GameLogic.end_player_phase = true
			return
		if Input.is_action_just_pressed("move_indicator_right"):
			indicator_index += 1
			var indicator_pos = static_pos_arr[indicator_index % (GRID_WIDTH*4)]
			indicator_tile.move_to_pos(indicator_pos.x, indicator_pos.y)
			indicator_tile.update_object_positions()
		if Input.is_action_just_pressed("move_indicator_left"):
			indicator_index -= 1
			var indicator_pos = static_pos_arr[indicator_index % (GRID_WIDTH*4)]
			indicator_tile.move_to_pos(indicator_pos.x, indicator_pos.y)
			indicator_tile.update_object_positions()
		if Input.is_action_just_pressed("turn_indicator_clockwise"):
			indicator_tile.rotate_clockwise()
		if Input.is_action_just_pressed("turn_indicator_counterclockwise"):
			indicator_tile.rotate_clockwise()
			indicator_tile.rotate_clockwise()
			indicator_tile.rotate_clockwise()

func move_row_horizontal(row, right):
	# move all tiles in row
	for tile in grid[row]:
		if right:
			tile.move_to_pos(tile.x+1, tile.y)
		else:
			tile.move_to_pos(tile.x-1, tile.y)
			
	# place indicator tile in grid
	if right:
		indicator_tile.move_to_pos(indicator_tile.x+1, indicator_tile.y)
	else:
		indicator_tile.move_to_pos(indicator_tile.x-1, indicator_tile.y)
	update_grid()

func move_row_vertical(column, up):
	# move all tiles in column
	for row in grid:
		var tile = row[column] 
		if up:
			tile.move_to_pos(tile.x, tile.y-1)
		else:
			tile.move_to_pos(tile.x, tile.y+1)
	
	# place indicator tile in grid
	if up:
		indicator_tile.move_to_pos(indicator_tile.x, indicator_tile.y-1)
	else:
		indicator_tile.move_to_pos(indicator_tile.x, indicator_tile.y+1)
	update_grid()

func update_grid():
	for tile in get_tree().get_nodes_in_group("tiles"):
		if tile.x < GRID_WIDTH && tile.y < GRID_HEIGHT && tile.x >= 0 && tile.y >= 0:
			grid[tile.y][tile.x] = tile
			tile.update_object_positions()
		else:
			indicator_tile = tile
			indicator_index = static_pos_arr.find(Vector2(indicator_tile.x, indicator_tile.y))
			indicator_tile.update_object_positions()
	grid_states.append([grid, indicator_tile])
	return grid

func create_indicator_pos_arr():
	var pos_arr = []
	for i in range(GRID_HEIGHT-1,-1,-1):
		pos_arr.append(Vector2(-1, i))
	for i in range(GRID_WIDTH):
		pos_arr.append(Vector2(i, -1))
	for i in range(GRID_HEIGHT):
		pos_arr.append(Vector2(GRID_HEIGHT, i))
	for i in range(GRID_WIDTH-1,-1,-1):
		pos_arr.append(Vector2(i, GRID_WIDTH))
	return pos_arr

func init_probabilities(object_types) -> void:
	# Reset total_weight to make sure it holds the correct value after initialization
	total_weight = 0.0
	# Iterate through the objects
	for obj_type in object_types.values():
		# Take current object weight and accumulate it
		total_weight += obj_type[0]
		# Take current sum and assign to the object.
		obj_type[1] = total_weight

func pick_some_object(object_types):
	# Roll the number
	var roll: float = rand_range(0.0, total_weight)
	# Now search for the first with acc_weight > roll
	for obj_type in object_types:
		if (object_types[obj_type][1] > roll):
			return obj_type
