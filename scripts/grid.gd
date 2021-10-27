extends Node

var GRID_HEIGHT = 7
var GRID_WIDTH = 7
var grid = []
var type_arr

var static_pos_arr = [[-1, 6], [-1, 5], [-1, 4], [-1, 3], [-1, 2], [-1, 1], [-1, 0], [0, -1], [1, -1], [2, -1], [3, -1], [4, -1], [5, -1], [6, -1], [7, 0], [7, 1], [7, 2], [7, 3], [7, 4], [7, 5], [7, 6], [6, 7], [5, 7], [4, 7], [3, 7], [2, 7], [1, 7], [0, 7]]
var indicator_index = 0
var indicator_tile

func _ready():
	type_arr = ["cross_n_e_s_w", "straight_n_s", "straight_e_w", "corner_n_w", "corner_n_e", "corner_s_w", "corner_s_e", "t_n_e_s", "t_n_e_w", "t_n_w_s", "t_s_e_w"]
	initialize_grid()
	
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			type_arr.shuffle()
			var tile = Tile.new(x,y, type_arr[0])
			add_child(tile)
			grid[y][x] = tile
		# TODO: Yoink weight system from seagull to distribute tiles
	
	# Place indicator cube
	var indicator_pos = static_pos_arr[indicator_index]
	indicator_tile = Tile.new(indicator_pos[0], indicator_pos[1], null)
	add_child(indicator_tile)
	
	Pathfinder.find_all_paths(grid)
	

func initialize_grid():
	for y in range(GRID_HEIGHT):
		grid.append([])
		for _x in range(GRID_WIDTH):
			grid[y].append(0)

func _physics_process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		if indicator_tile.x == -1 || indicator_tile.x == 7:
			move_row_horizontal(indicator_tile.y, indicator_tile.x == -1)
		if indicator_tile.y == -1 || indicator_tile.y == 7:
			move_row_vertical(indicator_tile.x, indicator_tile.y == 7)
	
	if Input.is_action_just_pressed("ui_right"):
		indicator_index += 1
		var indicator_pos = static_pos_arr[indicator_index%28]
		indicator_tile.move_to_pos(indicator_pos[0], indicator_pos[1])
	
	if Input.is_action_just_pressed("ui_left"):
		indicator_index -= 1
		var indicator_pos = static_pos_arr[indicator_index%28]
		indicator_tile.move_to_pos(indicator_pos[0], indicator_pos[1])
	
func move_row_horizontal(row, right):
	for tile in grid[row]:
		if right:
			tile.move_to_pos(tile.x+1, tile.y)
		else:
			tile.move_to_pos(tile.x-1, tile.y)
	update_grid()

func move_row_vertical(column, up):
	for row in grid:
		var tile = row[column]
		if up:
			tile.move_to_pos(tile.x, tile.y-1)
		else:
			tile.move_to_pos(tile.x, tile.y+1)
	update_grid()

# TODO: Add indicator tile, remove old tile, etc	
func update_grid():
	for tile in get_tree().get_nodes_in_group("tiles"):
		if tile.x < GRID_WIDTH && tile.y < GRID_HEIGHT:
			grid[tile.y][tile.x] = tile

#	for i in range(6,-1,-1):
#		var block = Tile.new(-1, i, null)
#		static_pos_arr.append([-1, i])
#		add_child(block)
#	for i in range(7):
#		var block = Tile.new(i, -1, null)
#		static_pos_arr.append([i, -1])
#		add_child(block)
#	for i in range(7):
#		var block = Tile.new(7, i, null)
#		static_pos_arr.append([7, i])
#		add_child(block)
#	for i in range(6,-1,-1):
#		var block = Tile.new(i, 7, null)
#		static_pos_arr.append([i, 7])
#		add_child(block)
#	print(static_pos_arr)
