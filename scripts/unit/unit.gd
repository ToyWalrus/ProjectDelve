extends Node2D

class_name Unit

# A UnitStats resource
export(Resource) var unit_stats

onready var _sprite := $Sprite as Sprite
onready var _controller := $Controller as CharacterController


func _ready():
	get_parent().get_node("Dungeon").set_active_unit(self)


func can_move_to(loc: Vector2, pathfinder: Pathfinder) -> bool:
	if _controller.is_moving:
		return false
	var cost = pathfinder.path_cost(position, loc)
	return cost != -1 and cost <= unit_stats.speed


func move_to(loc: Vector2, pathfinder: Pathfinder):
	return _controller.move_to(loc, pathfinder)
