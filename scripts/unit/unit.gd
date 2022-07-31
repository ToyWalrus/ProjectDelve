tool
extends Highlightable

class_name Unit

## A UnitData resource
export(Resource) var unit_data setget _init_vars

onready var _controller := $Controller as CharacterController

# Emits with parameters: newHP, maxHP?
signal hp_changed
export(int) var hp: int setget _update_hp

# Emits with parameters: newStamina, maxStamina?
signal stamina_changed
export(int) var stamina: int setget _update_stamina


func _ready():
	_init_vars(unit_data)


func path_to(loc: Vector2, pathfinder: Pathfinder) -> PoolVector2Array:
	return _controller.path_to(loc, pathfinder)


func can_move_to(loc: Vector2, pathfinder: Pathfinder, using_stamina = false, max_cost = 10000) -> bool:
	if _controller.is_moving:
		return false

	var cost = _controller.cost_to(loc, pathfinder)
	var extra = stamina if using_stamina else 0

	return cost != -1 and cost <= (unit_data.speed + extra) and cost <= max_cost


func move_to(loc: Vector2, pathfinder: Pathfinder):
	var cost = _controller.cost_to(loc, pathfinder)
	if cost > unit_data.speed:
		self.stamina -= cost - unit_data.speed
	yield(_controller.move_to(loc, pathfinder), "completed")
	return cost


# Takes amount - defense, returns actual amount of damage taken
func take_damage(amount: int) -> int:
	amount = [amount - unit_data.defense, 0].max()
	self.hp -= amount
	return amount


# Heals hp by given amount up to maxHP, returns amount healed
func heal(amount: int) -> int:
	var max_hp = unit_data.health
	var new_hp = hp + amount
	var healed = amount

	if new_hp > max_hp:
		healed = max_hp - hp
		new_hp = max_hp

	self.hp = new_hp
	return healed


func rest():
	# value will be clamped
	self.stamina = 1000


func _init_vars(new_data):
	if new_data:
		unit_data = new_data

	if unit_data.sprite and _sprite:
		var offset_ratio = -2.8
		_sprite.texture = unit_data.sprite
		_sprite.position = Vector2.ZERO
		_sprite.translate(Vector2(0, unit_data.sprite.get_size().y / offset_ratio))

	self.hp = unit_data.health
	rest()


func _update_stamina(newVal):
	if newVal == null or newVal == stamina:
		return
	if unit_data:
		var max_stamina = unit_data.stamina
		stamina = int(clamp(newVal, 0, max_stamina))
		emit_signal("stamina_changed", stamina, max_stamina)
	else:
		stamina = newVal
		emit_signal("stamina_changed", stamina, null)


func _update_hp(newValue):
	if newValue == null or newValue == hp:
		return
	if unit_data:
		var max_hp = unit_data.health
		hp = [newValue, max_hp].min()
		emit_signal("hp_changed", hp, max_hp)
	else:
		hp = newValue
		emit_signal("hp_changed", hp, null)
