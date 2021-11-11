extends Label


var t = 0.0
var fade_in
var fade_out
var fade_in_time
var fade_out_time
var show_for_time
var active_element

var ui_action = false

func _ready():
	pass

func _physics_process(delta):

	if ui_action:
		t += delta
		if fade_in == true:
			self.modulate.a += fade_in_time
			if self.modulate.a >= 1:
				self.modulate.a = 1
				fade_in = false
		if show_for_time != -1:
			if t >= show_for_time:
				if fade_out:
					self.modulate.a -= fade_out_time
					if self.modulate.a <= 0:
							self.modulate.a = 0
							self.visible = false
				else:		
					self.visible = false
						

func set_ui_text(ui_element_text):
	self.text = ui_element_text

func fade_in_and_show_ui(fade_time, show_time):
	fade_in = true
	fade_in_time = fade_time
	show_for_time = show_time
	self.modulate.a = 0
	self.visible = true


func fade_out_and_hide_ui(fade_time):
	fade_out = true
	fade_out_time = fade_time
	
