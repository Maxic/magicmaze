extends Camera

func _input(event):
	if event is InputEventMouseMotion:
		var position2D = get_viewport().get_mouse_position()
		var dropPlane  = Plane(Vector3(0, 10, 0), .1)
		var position3D = dropPlane.intersects_ray(project_ray_origin(position2D),project_ray_normal(position2D))
		var grid_pos = Vector2(round(position3D.x/2), round(position3D.z/2))
		GameLogic.highlight_tile(grid_pos)
