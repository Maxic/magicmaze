extends Node

var current_path = []
var paths_arr = []
var visited_tiles = {}
var junction_dict = {}


func find_all_paths(start_pos, grid):
	reset()
	var current_tile = start_pos
	var id = -1
	
	# A hero might be on the indicator tile, in that case, don't look for paths
	if current_tile.x < 0 or current_tile.x >= Grid.GRID_DIMENSION or \
		current_tile.y < 0 or current_tile.y >= Grid.GRID_DIMENSION:
			return []
	
	# initial fill of the dict
	for row in grid:
		for tile in row:
			visited_tiles[tile.vec_pos] = false
	
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
			neighbour_arr = find_all_neighbours(current_tile.x, current_tile.y, grid)
		
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
		
func find_all_neighbours(x, y, grid):
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

func reset():
	current_path = []
	paths_arr = []
	visited_tiles = {}
	junction_dict = {}
