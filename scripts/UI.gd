extends Control

var t = 0.0
var fade_in
var fade_out
var fade_in_time
var fade_out_time
var show_for_time
var active_element

var match_element
var match_element_text

var ui_action

onready var phase_text_label = $TopWideContainer/VBoxContainer/phase_text
onready var result_text_label = $CenterWideContainer/VBoxContainer/victory_text
onready var turn_text_label = $TopRightContainer/VBoxContainer/turn_text

func _ready():
	pass

func _physics_process(delta):
	
	if ui_action:
		active_element = match_element
		t += delta
		if fade_in == true:
			active_element.modulate.a += fade_in_time
			if active_element.modulate.a >= 1:
				active_element.modulate.a = 1
				fade_in = false
		if show_for_time != -1:
			if t >= show_for_time:
				if fade_out:
					active_element.modulate.a -= fade_out_time
					if active_element.modulate.a <= 0:
							active_element.modulate.a = 0
							active_element.visible = false
				else:		
					active_element.visible = false
						

func set_ui_text(ui_element_name, ui_element_text):
	match_element = find_ui_element(ui_element_name)
	match_element.text = ui_element_text

func fade_in_and_show_ui(ui_element_name, fade_time, show_time):
	fade_in = true
	fade_in_time = fade_time
	show_for_time = show_time
	match_element.modulate.a = 0
	match_element.visible = true
	ui_action = true


func fade_out_and_hide_ui(ui_element_name, fade_time):
	fade_out = true
	fade_out_time = fade_time
	
func find_ui_element(ui_element_name):
	t = 0.0
	match ui_element_name:
		
		"phase_text":
			match_element = phase_text_label
		"result_text":
			match_element = result_text_label
		"turn_text":
			match_element = turn_text_label
			
	return match_element
