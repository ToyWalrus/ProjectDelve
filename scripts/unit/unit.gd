tool
extends MouseListener

class_name Unit

# A UnitData resource
export(Resource) var unit_data

onready var _sprite := $Sprite as Sprite
onready var _controller := $Controller as CharacterController
onready var _hp_handler = $Health


func _ready():
	_hp_handler.max_hp = unit_data.health
	_hp_handler.current_hp = unit_data.health


func can_move_to(loc: Vector2, pathfinder: Pathfinder) -> bool:
	if _controller.is_moving:
		return false
	var cost = pathfinder.path_cost(position, loc)
	return cost != -1 and cost <= unit_data.speed


func move_to(loc: Vector2, pathfinder: Pathfinder):
	return _controller.move_to(loc, pathfinder)


# Takes amount - defense, returns actual amount of damage taken
func take_damage(amount: int) -> int:
	amount = [amount - unit_data.defense, 0].max()
	_hp_handler.current_hp -= amount
	return amount
