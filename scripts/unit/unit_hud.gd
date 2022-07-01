tool
extends Node2D

onready var _hp_bar = $HpBar
onready var _hp_color = $HpBar/HpColor
onready var _stamina_bar = $Stamina

export(Color) var healthy := Color("#20ea40") setget _set_healthy_color
export(Color) var wounded := Color("#eae220") setget _set_wounded_color
export(Color) var critical := Color("#e74322") setget _set_critical_color
export(Color) var stamina := Color("#e8a948") setget _set_stamina_color

const HEALTHY_CUTOFF = .95
const WOUNDED_CUTOFF = .5
const CRITICAL_CUTOFF = .2

var _percent := 1.0


func _ready():
	_update_hp_bar()


func _on_stamina_changed(newStamina, maxStamina):
	if maxStamina == null:
		maxStamina = 1
	_update_stamina_bar("total_segments", maxStamina)
	_update_stamina_bar("current_segments", newStamina)


func _on_hp_changed(newHp, maxHp):
	if maxHp == null:
		_percent = 1.0
	else:
		_percent = float(newHp) / float(maxHp)
	_update_hp_bar()


func _set_healthy_color(newVal):
	healthy = newVal
	_calculate_color()


func _set_wounded_color(newVal):
	wounded = newVal
	_calculate_color()


func _set_critical_color(newVal):
	critical = newVal
	_calculate_color()


func _set_stamina_color(newVal):
	stamina = newVal
	_update_stamina_bar("bar_color", newVal)


func _update_hp_bar():
	_calculate_color()
	_calculate_scale()


func _calculate_color():
	if not is_inside_tree():
		return
	if not _hp_color:
		_hp_color = $HpBar/HpColor

	var cutoff_diff: float

	if _percent >= HEALTHY_CUTOFF:
		_hp_color.color = healthy
	elif _percent < CRITICAL_CUTOFF:
		_hp_color.color = critical
	elif _percent >= WOUNDED_CUTOFF:
		cutoff_diff = HEALTHY_CUTOFF - WOUNDED_CUTOFF
		_hp_color.color = wounded.linear_interpolate(healthy, (_percent - WOUNDED_CUTOFF) / cutoff_diff)
	else:
		cutoff_diff = WOUNDED_CUTOFF - CRITICAL_CUTOFF
		_hp_color.color = critical.linear_interpolate(wounded, (_percent - CRITICAL_CUTOFF) / cutoff_diff)


func _calculate_scale():
	if not is_inside_tree():
		return
	if not _hp_bar:
		_hp_bar = $HpBar

	_hp_bar.rect_scale.x = _percent


func _update_stamina_bar(param, value):
	if not is_inside_tree():
		return
	if not _stamina_bar:
		_stamina_bar = $Stamina
	_stamina_bar.material.set_shader_param(param, value)
