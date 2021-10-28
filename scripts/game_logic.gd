extends Node

var grid
onready var main = get_node("/root/main")

func _ready():
	grid = main.create_grid()
	var paths = Pathfinder.find_all_paths(Vector2(0,0), grid)
	for path in paths:
		print(path)
	var hero = Hero.new(0,0)
	main.add_child(hero)
	hero.move_along_path(paths[0])
