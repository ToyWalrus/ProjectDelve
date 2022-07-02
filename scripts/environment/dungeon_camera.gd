extends Camera2D
class_name DungeonCamera


func screen_to_world_point(point: Vector2) -> Vector2:
	var transformed = point * zoom + position
	print("============================")
	print("Convert " + str(point) + " to world point")
	print("Camera position is " + str(position))
	print("Camera zoom is " + str(zoom))
	print("Returning " + str(transformed))
	print("")

	return transformed
