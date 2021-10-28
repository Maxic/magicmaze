extends Node

enum phase {ENEMY_INTENTION, PLAYER_PHASE, ENEMY_ACTION}

# state vars
var current_phase
var end_player_phase = false
var end_enemy_action_phase = false
var hero
# Nodes
onready var main = get_node("/root/main")

func _ready():
	Grid.create_grid()
	hero = Hero.new(0,0)
	main.add_child(hero)
	
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
			# setup next phase
			var paths = Pathfinder.find_all_paths(hero.vec_pos, Grid.grid)
			hero.remaining_path = paths[0]
			current_phase = phase.ENEMY_ACTION
			return
	if current_phase == phase.ENEMY_ACTION:
		if end_enemy_action_phase:
			current_phase = phase.PLAYER_PHASE
			return
