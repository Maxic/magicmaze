extends Spatial
class_name Monster
const CLASS_NAME = "Monster"

var x
var y
var vec_pos
var type
var sprite

var goblin_model = preload("res://scenes/goblin_model.tscn")

func _init(x_pos, y_pos, monster_type):
	self.x = x_pos
	self.y = y_pos
	self.vec_pos = Vector2(x,y)
	self.type = monster_type

	# Add to correct group
	name = "monster"
	add_to_group("monsters")
	
	# Move to correct position
	update_pos(x, y)
	
	# Set type and properties
	set_type_and_properties(type)

	
	# Initialize self in world
	add_child(sprite)
	GameLogic.add_object_to_tile(self, x, y)

func update_pos(x_pos, y_pos):
	translation = Vector3(x_pos*2, translation.y, y_pos*2)
	self.x = x_pos
	self.y = y_pos
	self.vec_pos = Vector2(x,y)
	
func set_type_and_properties(monster_type):
	match monster_type:
		"goblin":
			sprite = goblin_model.instance()
		_:
			sprite = null	
func die():
	GameLogic.remove_monster(self)
	queue_free()

func get_class(): return CLASS_NAME
