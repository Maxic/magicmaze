extends Spatial
class_name Monster

var x
var y
var vec_pos
var type


var goblin_sprite = preload("res://scenes/goblin_sprite.tscn")

func _init(x_pos, y_pos, monster_type):
	self.x = x_pos
	self.y = y_pos
	self.type = monster_type
	self.vec_pos = Vector2(x,y)
	
	# Add to correct group
	add_to_group("monsters")
	
	# Move to correct position
	update_pos(x, y)
	
	# sprite and stats based on type
	var sprite
	if type == "goblin":
		sprite = goblin_sprite.instance()
	
	# Initialize self in world
	add_child(sprite)
	GameLogic.add_object_to_tile(self, x, y)

func _physics_process(delta):
	pass
	
func update_pos(x_pos, y_pos):
	translation = Vector3(x_pos*2, translation.y, y_pos*2)
	self.x = x_pos
	self.y = y_pos
	self.vec_pos = Vector2(x,y)
	

