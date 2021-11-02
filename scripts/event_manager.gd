extends Node

onready var UI = get_node("/root/main/UI")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# 	UI.set_ui_text("name of UI node","text to be displayed")
#	UI.fade_in_and_show_ui("name of UI node",alpha added per frame until the value is 1, total display time)
#	UI.fade_out_and_hide_ui("name of UI node",alpha substracted per frame until value is 0)

func victory_msg():
	UI.set_ui_text("result_text","Victory!")
	UI.fade_in_and_show_ui("result_text",0.01,-1)

func your_are_dead_msg():
	UI.set_ui_text("result_text","You are dead")
	UI.fade_in_and_show_ui("result_text",0.01,-1)

func hero_intention_phase_msg():
	UI.set_ui_text("phase_text","The Heroes plan..")
	UI.fade_in_and_show_ui("phase_text",0.01,3)
	UI.fade_out_and_hide_ui("phase_text",0.05)
	
func hero_action_phase_msg():
	UI.set_ui_text("phase_text","The Heroes move!")
	UI.fade_in_and_show_ui("phase_text",0.01,3)
	UI.fade_out_and_hide_ui("phase_text",0.05)
	
func set_turn_timer(turn):
	UI.set_ui_text("turn_text",("Turn: " + str(turn)))
	UI.fade_in_and_show_ui("turn_text",0.01,-1)
