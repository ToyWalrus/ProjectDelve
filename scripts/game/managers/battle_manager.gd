extends Node

signal battle_started(attacker, defender)
signal battle_ended(attack_result, defend_result)

var _wheel_battle_scene = preload("res://scenes/WheelBattle.tscn")

var _attacker: Unit
var _defender: Unit
var _attack_result: WheelSectionData
var _defend_result: WheelSectionData

var _before_spin_hooks: Array[Callable] = []
var _after_spin_hooks: Array[Callable] = []


func init_battle(attacker: Unit, defender: Unit):
	_attacker = attacker
	_defender = defender
	_attack_result = null
	_defend_result = null
	register_after_spin_callback(Callable(self, "_apply_surges"))
	emit_signal("battle_started", _attacker, _defender)


# Make sure to call `init_battle()` first, and `cleanup_battle()` after.
# This function will return the same attack result and defend result
# as the battle_ended signal.
func do_battle():
	await _run_before_spin_hooks()
	await _battle_flow()
	await _run_after_spin_hooks()
	return [_attack_result, _defend_result]


func cleanup_battle():
	emit_signal("battle_ended", _attack_result, _defend_result)
	_before_spin_hooks.clear()
	_after_spin_hooks.clear()


# https://godotengine.org/qa/117094/does-gdscript-have-invocation-and-callbacks


# Before spin callbacks take the attacker and defender and return void.
func register_before_spin_callback(cb: Callable):
	_before_spin_hooks.append(cb)


func deregister_before_spin_callback(cb: Callable):
	_before_spin_hooks.erase(cb)


# After spin callbacks take an attack result and defend result as its two parameters,
# and returns the (possibly modified) attack result and defend result as an array.
func register_after_spin_callback(cb: Callable):
	_after_spin_hooks.append(cb)


func deregister_after_spin_callback(cb: Callable):
	_after_spin_hooks.erase(cb)


func _run_before_spin_hooks():
	if _before_spin_hooks.is_empty():
		await get_tree().process_frame
		return

	for cb in _before_spin_hooks:
		await Utils.await_result(cb.call(_attacker, _defender))


func _run_after_spin_hooks():
	if _after_spin_hooks.is_empty():
		await get_tree().process_frame
		return

	for cb in _after_spin_hooks:
		var updated_results = await Utils.await_result(cb.call(_attack_result, _defend_result))
		_attack_result = updated_results[0]
		_defend_result = updated_results[1]


func _battle_flow():
	var battle = _wheel_battle_scene.instantiate()

	# Add instantiated scene to current scene
	get_tree().current_scene.add_child(battle)

	battle.set_attacker(_attacker, _attacker.get_attack_wheel_sections())
	battle.set_defender(_defender, _defender.get_defense_wheel_sections())

	# Animate the scene in
	await battle.animate_in(1.25)

	# Wait a moment after animation completes
	await get_tree().create_timer(.5).timeout

	# Spin the wheels for X seconds and get the results [atk_result, def_result]
	var wheel_results = await battle.spin_wheels_for_duration(.75)

	_attack_result = wheel_results[0]
	_defend_result = wheel_results[1]

	# Wait a moment after spin completes
	await get_tree().create_timer(.75).timeout

	# Fade the scene out
	await battle.fade_out()

	# Remove battle scene from current scene
	get_tree().current_scene.remove_child(battle)


func _apply_surges(attack_result, defend_result):
	var surge_actions = _attacker.get_surge_actions()

	for action in surge_actions:
		attack_result = action.apply_to_wheel(attack_result)

	return [attack_result, defend_result]
