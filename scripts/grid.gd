tool
extends Node

var GRID_HEIGHT = 7
var GRID_WIDTH = 7
var grid = []
var type_arr

func _ready():
	type_arr = ["cross_n_e_s_w", "straight_n_s", "straight_e_w", "corner_n_w", "corner_n_e", "corner_s_w", "corner_s_e", "t_n_e_s", "t_n_e_w", "t_n_w_s", "t_s_e_w"]
	initialize_grid()
	
	# TODO: Place tiles according to width. 
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			randomize()
			type_arr.shuffle()
			var tile = Tile.new(x,y, type_arr[0])
			add_child(tile)
			grid[y][x] = tile
		# TODO: Yoink weight system from seagull to distribute tiles

func initialize_grid():
	for x in range(GRID_WIDTH):
		grid.append([])
		for _y in range(GRID_HEIGHT):
			grid[x].append(0)

func _physics_process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		move_row_vertical(1, true)
	
func move_row_horizontal(row, right):
	for tile in grid[row]:
		if right:
			tile.move_to_pos(tile.x+1, tile.y)
		else:
			tile.move_to_pos(tile.x-1, tile.y)

func move_row_vertical(column, up):
	for row in grid:
		var tile = row[column]
		if up:
			tile.move_to_pos(tile.x, tile.y-1)
		else:
			tile.move_to_pos(tile.x, tile.y+1)

