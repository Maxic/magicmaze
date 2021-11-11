extends Control

var t = 0.0
var fade_in
var fade_out
var fade_in_time
var fade_out_time
var show_for_time
var active_element

var ui_element
var match_element_text

var ui_action

onready var phase_text_label = $TopWideContainer/VBoxContainer/phase_text
onready var result_text_label = $CenterWideContainer/VBoxContainer/victory_text
onready var turn_text_label = $TopRightContainer/VBoxContainer/turn_text

func _ready():
	pass
	
	
# 	UI.set_ui_text("name of UI node","text to be displayed")
#	UI.fade_in_and_show_ui("name of UI node",alpha added per frame until the value is 1, total display time)
#	UI.fade_out_and_hide_ui("name of UI node",alpha substracted per frame until value is 0)

	
func victory_msg():
	result_text_label.set_ui_text("Victory!")
	result_text_label.fade_in_and_show_ui(0.01,-1)
	result_text_label.ui_action = true

func your_are_dead_msg():
	result_text_label.set_ui_text("You are dead")
	result_text_label.fade_in_and_show_ui(0.01,-1)
	result_text_label.ui_action = true

func hero_intention_phase_msg():
	phase_text_label.set_ui_text("The Heroes plan..")
	phase_text_label.fade_in_and_show_ui(0.1,3)
	phase_text_label.fade_out_and_hide_ui(0.05)
	phase_text_label.ui_action = true

func player_phase_msg():
	phase_text_label.set_ui_text("It's your turn")
	phase_text_label.fade_in_and_show_ui(0.1,2)
	phase_text_label.fade_out_and_hide_ui(0.05)
	phase_text_label.ui_action = true
	
func hero_action_phase_msg():
	phase_text_label.set_ui_text("The Heroes move!")
	phase_text_label.fade_in_and_show_ui(0.1,2)
	phase_text_label.fade_out_and_hide_ui(0.05)
	phase_text_label.ui_action = true
	
func set_turn_timer(turn):
	turn_text_label.set_ui_text(("Turn: " + str(turn)))
	turn_text_label.fade_in_and_show_ui(0.01,-1)
	turn_text_label.ui_action = true


	


