extends Spatial
class_name Treasure

var x
var y
var vec_pos
var type

var treasure_sprite = preload("res://scenes/treasure_sprite.tscn")

func _init(x_pos, y_pos):
	self.x = x_pos
	self.y = y_pos
	self.vec_pos = Vector2(x,y)
	
	# Add to correct group
	add_to_group("treasures")
	
	# Move to correct position
	move_to_pos(x, y)
	var sprite = treasure_sprite.instance()
	
	# Initialize self in world
	add_child(sprite)

func _physics_process(delta):
	pass
	
func move_to_pos(x_pos, y_pos):
	translation = Vector3(x_pos*2, translation.y, y_pos*2)
	self.x = x_pos
	self.y = y_pos
	self.vec_pos = Vector2(x,y)

