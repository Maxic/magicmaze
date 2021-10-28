extends Node

enum phase {ENEMY_INTENTION, PLAYER_PHASE, ENEMY_ACTION}

# state vars
var grid
var current_phase
var end_player_phase = false

# Nodes
onready var main = get_node("/root/main")

func _ready():
	grid = Grid.create_grid()
	current_phase = phase.ENEMY_INTENTION
	
func _physics_process(delta):
	if Input.is_action_just_pressed("test"):
		end_player_phase = true
	
	if current_phase == phase.ENEMY_INTENTION:
		# do stuff
		if true: # Skip tis for now
			current_phase = phase.PLAYER_PHASE
			return
	if current_phase == phase.PLAYER_PHASE:
		# enable movement of indicator tile.
		if end_player_phase: # TODO: Add correct condition
			grid = Grid.grid
			current_phase = phase.ENEMY_ACTION
			return
	if current_phase == phase.ENEMY_ACTION:
		var hero = Hero.new(0,0)
		main.add_child(hero)
		var paths = Pathfinder.find_all_paths(hero.vec_pos, grid)
		hero.move_along_path(paths[0])
		end_player_phase = false
		current_phase = phase.PLAYER_PHASE
		return
