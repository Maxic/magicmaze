extends Spatial
class_name Treasure
const CLASS_NAME = "Treasure"

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
	name = "treasure"
	add_to_group("treasures")
	
	# Move to correct position
	update_pos(x, y)
	var sprite = treasure_sprite.instance()
	
	# Initialize self in world
	add_child(sprite)
	GameLogic.add_object_to_tile(self, x, y)

func update_pos(x_pos, y_pos):
	translation = Vector3(x_pos*2, translation.y, y_pos*2)
	self.x = x_pos
	self.y = y_pos
	self.vec_pos = Vector2(x,y)

func picked_up():
	for object in Grid.grid[y][x].objects:
		if object.get_class() == CLASS_NAME:
			Grid.grid[y][x].remove_object(object)
	GameLogic.remove_treasure(self)
	GameLogic.hp -= 1
	queue_free()
	
func get_class(): return CLASS_NAME

