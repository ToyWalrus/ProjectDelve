extends CanvasLayer

class_name WheelBattle

@onready var _background = $CanvasModulate/Background
@onready var _screen_separator = $CanvasModulate/ScreenSeparator

@onready var _atk_wheel = $CanvasModulate/Attacking/AttackWheel
@onready var _atk_unit_sprite = $CanvasModulate/Attacking/AttackingUnit

@onready var _def_wheel = $CanvasModulate/Defending/DefenseWheel
@onready var _def_unit_sprite = $CanvasModulate/Defending/DefendingUnit

const _atk_wheel_position := Vector2(128, 472)
const _def_wheel_position := Vector2(876, 128)


func _ready():
	_reset_vars()


func _reset_vars():
	_atk_wheel.position = Vector2(-160, 760)
	_def_wheel.position = Vector2(1184, -160)
	_atk_unit_sprite.material.set_shader_parameter("fade_amount", 0)
	_def_unit_sprite.material.set_shader_parameter("fade_amount", 0)
	_screen_separator.material.set_shader_parameter("slider", 0)
	_background.color.a = 0
	$CanvasModulate.color = Color.WHITE


func fade_out(anim_time: float = 1):
	var tween := create_tween()
	tween.tween_property($CanvasModulate, "color", Color.TRANSPARENT, anim_time).from(Color.WHITE)
	await tween.finished


func animate_in(anim_time: float = 2):
	var remaining = anim_time
	var stage_1_time = anim_time / 10.0
	remaining -= stage_1_time

	var stage_2_time = remaining / 5.0
	remaining -= stage_2_time

	var stage_3_time = remaining

	var background_alpha_tween := create_tween()
	background_alpha_tween.tween_property(_background, "color:a", .35, stage_1_time).from(0).set_trans(
		Tween.TRANS_LINEAR
	)

	var separator_tween := create_tween().set_parallel()
	(
		# Animate in screen separator
		separator_tween
		. tween_property(_screen_separator.material, "shader_parameter/slider", 1, stage_1_time * 2)
		. from(0)
		. set_trans(Tween.TRANS_LINEAR)
		. set_ease(Tween.EASE_IN)
		. set_delay(stage_2_time)
	)
	(
		# Animate in attack wheel
		separator_tween
		. tween_property(_atk_wheel, "position", _atk_wheel_position, stage_2_time)
		. set_trans(Tween.TRANS_CUBIC)
		. set_ease(Tween.EASE_IN)
		. set_delay(stage_2_time)
	)
	(
		# Animate in defense wheel
		separator_tween
		. tween_property(_def_wheel, "position", _def_wheel_position, stage_2_time)
		. set_trans(Tween.TRANS_CUBIC)
		. set_ease(Tween.EASE_IN)
		. set_delay(stage_2_time)
	)

	await separator_tween.finished

	var unit_sprite_tween := create_tween().set_parallel()
	(
		# Fade in attack unit sprite
		unit_sprite_tween
		. tween_property(_atk_unit_sprite.material, "shader_parameter/fade_amount", 1, stage_3_time)
		. from(0)
		. set_trans(Tween.TRANS_CUBIC)
		. set_ease(Tween.EASE_IN_OUT)
	)
	(
		unit_sprite_tween
		# Fade in defense unit sprite
		. tween_property(_def_unit_sprite.material, "shader_parameter/fade_amount", 1, stage_3_time)
		. from(0)
		. set_trans(Tween.TRANS_CUBIC)
		. set_ease(Tween.EASE_IN_OUT)
	)

	await unit_sprite_tween.finished


func spin_attack_wheel():
	_atk_wheel.spin_wheel()


func spin_defense_wheel():
	_def_wheel.spin_wheel()


func stop_attack_wheel():
	_atk_wheel.stop_wheel()
	var result = await _atk_wheel.wheel_stopped
	return result


func stop_defense_wheel():
	_def_wheel.stop_wheel()
	var result = await _def_wheel.wheel_stopped
	return result


func set_attacker(attacker, wheel_sections):
	_atk_unit_sprite.texture = attacker.unit_data.sprite
	_atk_wheel.wheel_sections = wheel_sections


func set_defender(defender, wheel_sections):
	_def_unit_sprite.texture = defender.unit_data.sprite
	_def_wheel.wheel_sections = wheel_sections


func spin_wheels_for_duration(duration = 1.25):
	_atk_result = null
	_def_result = null

	Utils.connect_signal(_atk_wheel, "wheel_stopped", self, "_attack_wheel_stopped", [], CONNECT_ONE_SHOT)
	Utils.connect_signal(_def_wheel, "wheel_stopped", self, "_defend_wheel_stopped", [], CONNECT_ONE_SHOT)

	_atk_wheel.spin_wheel()
	_def_wheel.spin_wheel()

	await get_tree().create_timer(duration + max(_atk_wheel.startup_time, _def_wheel.startup_time)).timeout

	_atk_wheel.stop_wheel()
	_def_wheel.stop_wheel()

	await self._both_wheels_stopped

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
