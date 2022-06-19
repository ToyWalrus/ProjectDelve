extends Node2D

class_name CharacterController

export(float) var character_speed = 100

var is_moving: bool = false setget , _get_is_moving
var current_destination

signal _arrived_at_path_point


func move_to(loc: Vector2, pathfinder: Pathfinder):
	var path = pathfinder.find_path(position, loc)
	if not path.empty():
		is_moving = true
		yield(_follow_path(path), "completed")
		is_moving = false


func _get_is_moving():
	return is_moving


func _follow_path(path: PoolVector2Array):
	while not path.empty():
		current_destination = path[0]
		path.remove(0)

		yield(self, "_arrived_at_path_point")

		current_destination = null


func _process(delta: float):
	if current_destination:
		position = position.move_toward(current_destination, delta * character_speed)

		if position.is_equal_approx(current_destination):
			emit_signal("_arrived_at_path_point")
