extends Camera

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		var position2D = get_viewport().get_mouse_position()
		var dropPlane  = Plane(Vector3(0, 10, 0), .1)
		var position3D = dropPlane.intersects_ray(project_ray_origin(position2D),project_ray_normal(position2D))
		var grid_pos = Vector2(round(position3D.x/2), round(position3D.z/2))
		GameLogic.highlight_tile(grid_pos)

#		var space_state = get_world().direct_space_state
#		var from = project_ray_origin(event.position)
#		var to = from + project_ray_normal(event.position) * 1000
#		var intersection = space_state.intersect_ray(from, to)
#		if intersection:
#			var intersect_pos = intersection['position']
#			var terrain_normal = intersection['normal']
#			terrain_normal = terrain_normal.normalized()
#			print(intersect_pos)
#			print(terrain_normal)
#			print()
