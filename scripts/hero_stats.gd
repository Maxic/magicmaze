extends Sprite3D

var hero

func _ready():
	hero = get_parent()
	texture = $Viewport.get_texture()
	$Viewport/Label.text = str(hero.turn_order)
