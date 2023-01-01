extends CanvasLayer

class_name WheelBattle

onready var _background = $Background
onready var _screen_separator = $ScreenSeparator

onready var _atk_wheel = $Attacking/AttackWheel
onready var _atk_unit_sprite = $Attacking/AttackingUnit

onready var _def_wheel = $Defending/DefenseWheel
onready var _def_unit_sprite = $Defending/DefendingUnit

const _atk_wheel_position := Vector2(128, 472)
const _def_wheel_position := Vector2(876, 128)


func _ready():
	_reset_vars()


func _reset_vars():
	_atk_wheel.position = Vector2(-160, 760)
	_def_wheel.position = Vector2(1184, -160)
	_atk_unit_sprite.material.set_shader_param("fade_amount", 0)
	_def_unit_sprite.material.set_shader_param("fade_amount", 0)
	_screen_separator.material.set_shader_param("slider", 0)
	_background.color.a = 0


func fade_out(anim_time: float = 1):
	$Background/Tween.interpolate_property(self, "modulate", Color.white, Color.transparent, anim_time)
	$Background/Tween.start()
	yield($Background/Tween, "tween_completed")


func animate_in(anim_time: float = 2):
	var remaining = anim_time
	var stage_1_time = anim_time / 10.0
	remaining -= stage_1_time

	var stage_2_time = remaining / 5.0
	remaining -= stage_2_time

	var stage_3_time = remaining

	$Background/Tween.interpolate_property(_background, "color:a", 0, .1, stage_1_time, Tween.TRANS_LINEAR)
	$Background/Tween.start()
	yield($Background/Tween, "tween_completed")

	$ScreenSeparator/Tween.interpolate_property(
		_screen_separator.material,
		"shader_param/slider",
		0,
		1,
		stage_1_time * 2.0,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN,
		stage_2_time
	)
	$ScreenSeparator/Tween.start()

	$Attacking/Tween.interpolate_property(
		_atk_wheel, "position", _atk_wheel.position, _atk_wheel_position, stage_2_time, Tween.TRANS_CUBIC, Tween.EASE_IN
	)
	$Defending/Tween.interpolate_property(
		_def_wheel, "position", _def_wheel.position, _def_wheel_position, stage_2_time, Tween.TRANS_CUBIC, Tween.EASE_IN
	)
	$Attacking/Tween.start()
	$Defending/Tween.start()
	yield($Attacking/Tween, "tween_completed")

	$Attacking/Tween.interpolate_property(
		_atk_unit_sprite.material, "shader_param/fade_amount", 0, 1, stage_3_time, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT
	)
	$Defending/Tween.interpolate_property(
		_def_unit_sprite.material, "shader_param/fade_amount", 0, 1, stage_3_time, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT
	)
	$Attacking/Tween.start()
	$Defending/Tween.start()
	yield($Attacking/Tween, "tween_completed")


func spin_attack_wheel():
	_atk_wheel.spin_wheel()


func spin_defense_wheel():
	_def_wheel.spin_wheel()


func stop_attack_wheel():
	_atk_wheel.stop_wheel()
	var result = yield(_atk_wheel, "wheel_stopped")
	return result


func stop_defense_wheel():
	_def_wheel.stop_wheel()
	var result = yield(_def_wheel, "wheel_stopped")
	return result


func set_attacker(attacker, wheel_sections):
	_atk_unit_sprite = attacker.unit_data.sprite
	_atk_wheel.wheel_sections = wheel_sections


func set_defender(defender, wheel_sections):
	_def_unit_sprite = defender.unit_data.sprite
	_def_wheel.wheel_sections = wheel_sections


func spin_wheels_for_duration(duration = 1.25):
	_atk_result = null
	_def_result = null

	Utils.connect_signal(_atk_wheel, "wheel_stopped", self, "_attack_wheel_stopped", [], CONNECT_ONESHOT)
	Utils.connect_signal(_def_wheel, "wheel_stopped", self, "_defend_wheel_stopped", [], CONNECT_ONESHOT)

	_atk_wheel.spin_wheel()
	_def_wheel.spin_wheel()

	yield(get_tree().create_timer(duration + max(_atk_wheel.startup_time, _def_wheel.startup_time)), "timeout")

	_atk_wheel.stop_wheel()
	_def_wheel.stop_wheel()

	yield(self, "_both_wheels_stopped")

	return [_atk_result, _def_result]


var _atk_result
var _def_result
signal _both_wheels_stopped


func _attack_wheel_stopped(result):
	_atk_result = result
	if _def_result != null:
		emit_signal("_both_wheels_stopped")


func _defend_wheel_stopped(result):
	_def_result = result
	if _atk_result != null:
		emit_signal("_both_wheels_stopped")
