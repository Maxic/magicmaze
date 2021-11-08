extends Node

var current_path = []
var paths_arr = []
var visited_tiles = {}
var junction_dict = {}

func find_shortest_paths(start_pos, grid):
	var shortest_paths = {}
	var possible_paths = find_all_paths(start_pos, grid)
	var treasure_path = find_shortest_treasure_path(possible_paths)
	var monster_path = find_shortest_monster_path(possible_paths)
	
	if treasure_path != []:
		shortest_paths["treasure"] = treasure_path
	if monster_path != []:
		shortest_paths["monster"] = monster_path
	return shortest_paths
	
func find_shortest_treasure_path(paths):
	var shortest_path
	var treasure_paths = find_all_treasure_paths(paths)
	var shortest_path_size = Grid.GRID_DIMENSION * Grid.GRID_DIMENSION
	if treasure_paths:
		for path in treasure_paths:
			if path.size() < shortest_path_size:
				shortest_path = path.duplicate()
				shortest_path_size = path.size()
		return shortest_path
	else:
		return []
	
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
				for _i in range(end_path_index+1, path.size()):
					path.remove(end_path_index+1)
				treasure_paths.append(path)
	return treasure_paths

func find_shortest_monster_path(paths):
	var shortest_path
	var monster_paths = find_all_monster_paths(paths)
	var shortest_path_size = Grid.GRID_DIMENSION * Grid.GRID_DIMENSION
	if monster_paths:
		for path in monster_paths:
			if path.size() < shortest_path_size:
				shortest_path = path.duplicate()
				shortest_path_size = path.size()
		return shortest_path
	else:
		return []
	
func find_all_monster_paths(paths):
	var monster_paths = []
	var monster_pos_arr = []
	for monster in GameLogic.monster_array:
		monster_pos_arr.append(monster.vec_pos)
	for path in paths:
		for pos in path:
			var obtainable_monster_index = monster_pos_arr.find(pos)
			if obtainable_monster_index >= 0:
				var end_path_index = path.find(monster_pos_arr[obtainable_monster_index])
				for _i in range(end_path_index+1, path.size()):
					path.remove(end_path_index+1)
				monster_paths.append(path)
	return monster_paths

func find_all_paths(start_pos, grid):
	reset()
	var current_tile = start_pos
	var id = -1
	
	# A hero might be on the indicator tile, in that case, don't look for paths
	if current_tile.x < 0 or current_tile.x >= Grid.GRID_DIMENSION or \
		current_tile.y < 0 or current_tile.y >= Grid.GRID_DIMENSION:
			return []
	
	# initial fill of the dict
	initialize_visited_tiles(grid)
	
	while current_tile != null or junction_dict.size() > 0:
		var neighbour_arr = []
		id += 1
		var rand_id = -1
		
		# If current tile is null, revisit a junction
		if current_tile == null:			
			rand_id = junction_dict.keys()[0]
			current_tile = junction_dict.get(rand_id)["current_tile"]
			visited_tiles = junction_dict.get(rand_id)["visited_tiles"]
			neighbour_arr = junction_dict.get(rand_id)["neighbour_arr"]
			current_path = junction_dict.get(rand_id)["current_path"]
		else:
			current_path.append(current_tile)
		
		# Mark current path as visited
		visited_tiles[current_tile] = true
		
		# Find all tiles we can move towards
		if neighbour_arr == []:
			neighbour_arr = find_all_neighbours(Vector2(current_tile.x, current_tile.y), grid)
		
		# With 0 neighbours stop and save current path
		if neighbour_arr.size() == 0:
			paths_arr.append(current_path.duplicate())
			current_tile = null
		# If we only have 1 choice, go that way
		elif neighbour_arr.size() == 1:
			# if this was a junction, it should be removed now
			if rand_id > -1:
				junction_dict.erase(rand_id)
				
			# Update current tile to next tile
			current_tile = neighbour_arr[0]
		# If we arrive at a junction, save that spot to revisit later.
		elif neighbour_arr.size() > 1:
			# first pick a path and remove that path from the array
			neighbour_arr.shuffle()
			var next_tile = neighbour_arr[0]
			neighbour_arr.remove(0)
			
			# then add this point as a junction.
			# We add the current visited tiles dict here so we can load it later
			junction_dict[id] =  {
				"current_tile" : current_tile,
				"visited_tiles" : visited_tiles.duplicate(),
				"neighbour_arr" : neighbour_arr.duplicate(), 
				"current_path" : current_path.duplicate() 
			}
			
			# Finally, set current tile to the next tile
			current_tile = next_tile
	return paths_arr
		
func find_all_neighbours(pos, grid):
	var x = pos.x
	var y = pos.y
	var valid_neighbour_arr = []
	var tile = grid[y][x]
	
	# north
	if not y-1 < 0 and tile.north_open:
		var neighbour_tile = grid[y-1][x]
		if not visited_tiles[neighbour_tile.vec_pos] and neighbour_tile.south_open:
			valid_neighbour_arr.append(Vector2(neighbour_tile.x, neighbour_tile.y))
	# south
	if not y+1 >= grid.size() and tile.south_open: # This assumes we have a square grid (!)
		var neighbour_tile = grid[y+1][x]
		if not visited_tiles[neighbour_tile.vec_pos] and neighbour_tile.north_open:
			valid_neighbour_arr.append(Vector2(neighbour_tile.x, neighbour_tile.y))
	# west
	if not x-1 < 0 and tile.west_open:
		var neighbour_tile = grid[y][x-1]
		if not visited_tiles[neighbour_tile.vec_pos] and neighbour_tile.east_open:
			valid_neighbour_arr.append(Vector2(neighbour_tile.x, neighbour_tile.y))
	# east
	if not x+1 >= grid.size() and tile.east_open: # This assumes we have a square grid (!)
		var neighbour_tile = grid[y][x+1]
		if not visited_tiles[neighbour_tile.vec_pos] and neighbour_tile.west_open:
			valid_neighbour_arr.append(Vector2(neighbour_tile.x, neighbour_tile.y))
	
	return valid_neighbour_arr

func tiles_are_connected(tile_1, tile_2, grid):
	initialize_visited_tiles(grid)
	var open_tiles = find_all_neighbours(tile_1, grid)
	for tile in open_tiles:
		if tile_2 == tile:
			return true
	return false
		
func initialize_visited_tiles(grid):
	# initial fill of the dict
	for row in grid:
		for tile in row:
			visited_tiles[tile.vec_pos] = false

func reset():
	current_path = []
	paths_arr = []
	visited_tiles = {}
	junction_dict = {}
