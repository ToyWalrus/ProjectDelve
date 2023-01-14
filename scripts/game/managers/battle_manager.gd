extends Node

signal battle_started(attacker, defender)
signal battle_ended(attack_result, defend_result)

var _wheel_battle_scene = preload("res://scenes/WheelBattle.tscn")

var _attacker: Unit
var _defender: Unit
var _attack_result: WheelSectionData
var _defend_result: WheelSectionData

var _before_spin_hooks := []
var _after_spin_hooks := []


func init_battle(attacker: Unit, defender: Unit):
	_attacker = attacker
	_defender = defender
	_attack_result = null
	_defend_result = null
	emit_signal("battle_started", _attacker, _defender)


# Make sure to call `init_battle()` first, and `cleanup_battle()` after.
# This function will return the same attack result and defend result
# as the battle_ended signal.
func do_battle():
	yield(_run_before_spin_hooks(), "completed")
	yield(_battle_flow(), "completed")
	yield(_run_after_spin_hooks(), "completed")
	return [_attack_result, _defend_result]


func cleanup_battle():
	emit_signal("battle_ended", _attack_result, _defend_result)
	_before_spin_hooks.clear()
	_after_spin_hooks.clear()


# https://godotengine.org/qa/117094/does-gdscript-have-invocation-and-callbacks


# Before spin callbacks take the attacker and defender and return void.
func register_before_spin_callback(cb: FuncRef):
	_before_spin_hooks.append(cb)


func deregister_before_spin_callback(cb: FuncRef):
	_before_spin_hooks.erase(cb)


# After spin callbacks take an attack result and defend result as its two parameters,
# and returns the (possibly modified) attack result and defend result as an array.
func register_after_spin_callback(cb: FuncRef):
	_after_spin_hooks.append(cb)


func deregister_after_spin_callback(cb: FuncRef):
	_after_spin_hooks.erase(cb)


func _run_before_spin_hooks():
	if _before_spin_hooks.empty():
		yield(get_tree(), "idle_frame")
		return

	for cb in _before_spin_hooks:
		yield(Utils.yield_for_result(cb.call_funcv([_attacker, _defender])), "completed")


func _run_after_spin_hooks():
	if _after_spin_hooks.empty():
		yield(get_tree(), "idle_frame")
		return

	for cb in _after_spin_hooks:
		var updated_results = yield(
			Utils.yield_for_result(cb.call_funcv([_attack_result, _defend_result])), "completed"
		)
		_attack_result = updated_results[0]
		_defend_result = updated_results[1]


func _battle_flow():
	var battle = _wheel_battle_scene.instance()

	# Add instantiated scene to current scene
	get_tree().current_scene.add_child(battle)

	battle.set_attacker(_attacker, _attacker.get_attack_wheel_sections())
	battle.set_defender(_defender, _defender.get_defense_wheel_sections())

	# Animate the scene in
	yield(battle.animate_in(1.25), "completed")

	# Wait a moment after animation completes
	yield(get_tree().create_timer(.5), "timeout")

	# Spin the wheels for X seconds and get the results [atk_result, def_result]
	var wheel_results = yield(battle.spin_wheels_for_duration(.75), "completed")

	_attack_result = wheel_results[0]
	_defend_result = wheel_results[1]

	# Wait a moment after spin completes
	yield(get_tree().create_timer(.75), "timeout")

	# Fade the scene out
	yield(battle.fade_out(), "completed")

	# Remove battle scene from current scene
	get_tree().current_scene.remove_child(battle)
