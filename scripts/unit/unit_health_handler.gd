tool
extends Node2D

onready var _hp_bar = $HpBar
onready var _hp_color = $HpBar/HpColor

export(int) var max_hp := 6 setget _set_max_hp
export(int) var current_hp := 6 setget _set_hp

export(Color) var healthy := Color("#20ea40") setget _set_healthy_color
export(Color) var wounded := Color("#eae220") setget _set_wounded_color
export(Color) var critical := Color("#e74322") setget _set_critical_color

const HEALTHY_CUTOFF = .95
const WOUNDED_CUTOFF = .5
const CRITICAL_CUTOFF = .2


func _ready():
	_update_hp_bar()


func _set_max_hp(newVal):
	max_hp = newVal
	if max_hp < current_hp:
		current_hp = max_hp
	_update_hp_bar()


func _set_hp(newVal):
	if newVal > max_hp:
		newVal = max_hp
	current_hp = newVal
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


func _update_hp_bar():
	_calculate_color()
	_calculate_scale()


func _calculate_color():
	if not is_inside_tree():
		return
	if not _hp_color:
		_hp_color = $HpBar/HpColor

	var percent := _get_hp_percent()
	var cutoff_diff: float

	if percent >= HEALTHY_CUTOFF:
		_hp_color.color = healthy
	elif percent < CRITICAL_CUTOFF:
		_hp_color.color = critical
	elif percent >= WOUNDED_CUTOFF:
		cutoff_diff = HEALTHY_CUTOFF - WOUNDED_CUTOFF
		_hp_color.color = wounded.linear_interpolate(healthy, (percent - WOUNDED_CUTOFF) / cutoff_diff)
	else:
		cutoff_diff = WOUNDED_CUTOFF - CRITICAL_CUTOFF
		_hp_color.color = critical.linear_interpolate(wounded, (percent - CRITICAL_CUTOFF) / cutoff_diff)


func _calculate_scale():
	if not is_inside_tree():
		return
	if not _hp_bar:
		_hp_bar = $HpBar

	_hp_bar.rect_scale.x = _get_hp_percent()


func _get_hp_percent() -> float:
	return float(current_hp) / float(max_hp)
