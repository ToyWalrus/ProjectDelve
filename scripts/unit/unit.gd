tool
extends MouseListener

class_name Unit

# A UnitData resource
export(Resource) var unit_data

onready var _sprite := $Sprite as Sprite
onready var _controller := $Controller as CharacterController

# Emits with parameters: newHP, maxHP?
signal hp_changed
export(int) var hp: int setget _update_hp


func _ready():
	self.hp = unit_data.health


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
	self.hp -= amount
	return amount


# Heals hp by given amount up to maxHP, returns amount healed
func heal(amount: int) -> int:
	var maxHp = unit_data.health
	var newHp = hp + amount
	var healed = amount

	if newHp > maxHp:
		healed = maxHp - hp
		newHp = maxHp

	self.hp = newHp
	return healed


func _update_hp(newValue: int):
	if newValue == hp:
		return
	hp = newValue
	if unit_data:
		emit_signal("hp_changed", newValue, unit_data.health)
	else:
		emit_signal("hp_changed", newValue, null)
