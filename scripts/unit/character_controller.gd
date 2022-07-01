extends Node2D

class_name CharacterController

export(float) var character_speed = 100

var is_moving := false setget , _get_is_moving

const _path_ids := {}
const _path_costs := {}
var _current_destination

signal _arrived_at_path_point


func path_to(loc: Vector2, pathfinder: Pathfinder) -> PoolVector2Array:
	_ensure_path_to(loc, pathfinder)
	return pathfinder.get_point_path_from_ids(_path_ids[_key(loc, pathfinder)])


func cost_to(loc: Vector2, pathfinder: Pathfinder):
	_ensure_path_to(loc, pathfinder)
	var key = _key(loc, pathfinder)

	if not _path_costs.has(key):
		_path_costs[key] = pathfinder.cost_of_path(_path_ids[key])

	return _path_costs[key]


func move_to(loc: Vector2, pathfinder: Pathfinder):
	var path = path_to(loc, pathfinder)
	if not path.empty():
		is_moving = true
		yield(_follow_path(path), "completed")
		is_moving = false


func _get_is_moving():
	return is_moving


func _follow_path(path: PoolVector2Array):
	while not path.empty():
		_current_destination = path[0]
		path.remove(0)

		yield(self, "_arrived_at_path_point")

		_current_destination = null


func _process(delta: float):
	if _current_destination:
		var pos = self.position
		pos = pos.move_toward(_current_destination, delta * character_speed)

		self.position = pos
		if pos.is_equal_approx(_current_destination):
			emit_signal("_arrived_at_path_point")


# https://godotengine.org/qa/74149/add-setget-onto-existing-variable-from-inherited-class
func _get(property):
	if property == "position":
		return get_parent().position


func _set(property, value):
	if property == "position":
		_path_ids.clear()
		_path_costs.clear()
		get_parent().position = value


func _ensure_path_to(loc: Vector2, pathfinder: Pathfinder):
	var key = _key(loc, pathfinder)
	if not _path_ids.has(key):
		_path_ids[key] = pathfinder.get_id_path(self.position, loc)


func _key(loc: Vector2, pathfinder: Pathfinder) -> String:
	return str(pathfinder.convert_to_map_point(loc))
