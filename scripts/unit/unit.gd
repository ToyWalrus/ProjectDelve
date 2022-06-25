tool
extends MouseListener

class_name Unit

# A UnitStats resource
export(Resource) var unit_stats

onready var _sprite := $Sprite as Sprite
onready var _controller := $Controller as CharacterController
onready var _hp_handler = $Health


func _ready():
	_hp_handler.max_hp = unit_stats.health
	_hp_handler.current_hp = unit_stats.health


func can_move_to(loc: Vector2, pathfinder: Pathfinder) -> bool:
	if _controller.is_moving:
		return false
	var cost = pathfinder.path_cost(position, loc)
	return cost != -1 and cost <= unit_stats.speed


func move_to(loc: Vector2, pathfinder: Pathfinder):
	return _controller.move_to(loc, pathfinder)


func take_damage(amount: int):
	_hp_handler.current_hp -= amount
