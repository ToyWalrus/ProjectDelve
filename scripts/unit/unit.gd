tool
extends Highlightable

class_name Unit

## A UnitData resource
export(Resource) var unit_data setget _init_vars

onready var _controller := $Controller as UnitController

# Emits with parameters: newHP, maxHP?
signal hp_changed
export(int) var hp: int setget _update_hp

# Emits with parameters: newStamina, maxStamina?
signal stamina_changed
export(int) var stamina: int setget _update_stamina

# Unit skills available for use (array of SkillDef)
export(Array) var skills := []


func _ready():
	_init_vars(unit_data)
	_controller.set_unit(self)


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
	amount = [amount, 0].max()
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


func get_attack_wheel_sections() -> Array:
	# TODO: factor in current weapon
	var sections := []

	sections.append(_create_dummy_attack_wheel_section(1, 1, 0, false, .35))
	sections.append(_create_dummy_attack_wheel_section(2, 0, 0, false, .2))
	sections.append(_create_dummy_attack_wheel_section(0, 2, 0, false, .2))
	sections.append(_create_dummy_attack_wheel_section(0, 0, 0, true, .15))

	return sections


func get_defense_wheel_sections() -> Array:
	# TODO: factor in current armor
	var sections := []

	sections.append(_create_dummy_defense_wheel_section(1, .2))
	sections.append(_create_dummy_defense_wheel_section(2, .35))
	sections.append(_create_dummy_defense_wheel_section(1, .2))
	sections.append(_create_dummy_defense_wheel_section(3, .15))

	return sections


func _create_dummy_attack_wheel_section(atk = 0, special = 0, atk_range = 0, miss = false, percent = 1) -> WheelSectionData:
	var sec = WheelSectionData.new()
	sec.attack_points = atk
	sec.special_points = special
	sec.range_points = atk_range
	sec.miss = miss
	sec.percent_of_wheel = percent
	return sec


func _create_dummy_defense_wheel_section(def = 0, percent = 1) -> WheelSectionData:
	var sec = WheelSectionData.new()
	sec.defense_points = def
	sec.percent_of_wheel = percent
	sec.miss = def == 0
	return sec


func _init_vars(new_data):
	if new_data:
		unit_data = new_data
		unit_data.set_meta("unit", self)

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
