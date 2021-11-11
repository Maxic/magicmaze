extends Node

var UI

func _ready():
	reset()

func reset():
	UI = get_node("/root/main/UI")


func victory_msg():
	UI.victory_msg()

func your_are_dead_msg():
	UI.your_are_dead_msg()

func hero_intention_phase_msg():
	UI.hero_intention_phase_msg()

func player_phase_msg():
	UI.player_phase_msg()
	
func hero_action_phase_msg():
	UI.hero_action_phase_msg()
	
func set_turn_timer(turn):
	UI.set_turn_timer(turn)

