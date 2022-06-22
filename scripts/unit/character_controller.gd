extends Node2D

class_name CharacterController

export(float) var character_speed = 100
export(Resource) var unit_stats

var is_moving: bool = false setget , _get_is_moving
var current_destination

signal _arrived_at_path_point


func move_to(loc: Vector2, pathfinder: Pathfinder):
	var path = pathfinder.find_path(get_parent().position, loc)
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
		var pos = self.position
		pos = pos.move_toward(current_destination, delta * character_speed)

		self.position = pos
		if pos.is_equal_approx(current_destination):
			emit_signal("_arrived_at_path_point")


# https://godotengine.org/qa/74149/add-setget-onto-existing-variable-from-inherited-class
func _get(property):
	if property == "position":
		return get_parent().position


func _set(property, value):
	if property == "position":
		get_parent().position = value
