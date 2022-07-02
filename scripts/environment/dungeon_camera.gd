extends Camera2D
class_name DungeonCamera


func screen_to_world_point(point: Vector2) -> Vector2:
	return point * zoom + position
