extends Node

# Grid must be square
var GRID_DIMENSION = 7
var GRID_HEIGHT = GRID_DIMENSION
var GRID_WIDTH = GRID_DIMENSION

var grid = []
var type_arr = [
	"cross_n_e_s_w", 
	"straight_n_s", 
	"straight_e_w", 
	"corner_n_w", 
	"corner_n_e", 
	"corner_s_w", 
	"corner_s_e", 
	"t_n_e_s", 
	"t_n_e_w", 
	"t_n_w_s", 
	"t_s_e_w"
	]

var static_pos_arr = []
var indicator_index = 0
var indicator_tile

func create_grid():
	# Initialize grid with 0's
	initialize_grid()
	
	# Fill grid with actual tiles
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			#randomize()
			type_arr.shuffle()
			var tile = Tile.new(x,y, type_arr[0])
			add_child(tile)
			grid[y][x] = tile
		# TODO: Yoink weight system from seagull to distribute tiles
	
	# Create static position array for indicator block
	static_pos_arr = create_indicator_pos_arr()
	
	# Place indicator cube
	var indicator_pos = static_pos_arr[indicator_index]
	type_arr.shuffle()
	indicator_tile = Tile.new(indicator_pos.x, indicator_pos.y, type_arr[0])
	add_child(indicator_tile)

func initialize_grid():
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
		if Input.is_action_just_pressed("move_indicator_right"):
			indicator_index += 1
			var indicator_pos = static_pos_arr[indicator_index % (GRID_WIDTH*4)]
			indicator_tile.move_to_pos(indicator_pos.x, indicator_pos.y)
		if Input.is_action_just_pressed("move_indicator_left"):
			indicator_index -= 1
			var indicator_pos = static_pos_arr[indicator_index % (GRID_WIDTH*4)]
			indicator_tile.move_to_pos(indicator_pos.x, indicator_pos.y)

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
			
		else:
			indicator_tile = tile
			indicator_index = static_pos_arr.find(Vector2(indicator_tile.x, indicator_tile.y))

func create_indicator_pos_arr():
	var pos_arr = []
	for i in range(GRID_HEIGHT-1,-1,-1):
		var block = Tile.new(-1, i, null)
		pos_arr.append(Vector2(-1, i))
	for i in range(GRID_WIDTH):
		var block = Tile.new(i, -1, null)
		pos_arr.append(Vector2(i, -1))
	for i in range(GRID_HEIGHT):
		var block = Tile.new(GRID_HEIGHT, i, null)
		pos_arr.append(Vector2(GRID_HEIGHT, i))
	for i in range(GRID_WIDTH-1,-1,-1):
		var block = Tile.new(i, GRID_WIDTH, null)
		pos_arr.append(Vector2(i, GRID_WIDTH))
	return pos_arr
