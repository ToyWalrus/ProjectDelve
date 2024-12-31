@tool
extends Resource

class_name WheelSectionData

@export var percent_of_wheel := 1.0: set = _set_percent
@export var section_name: String = "": set = _set_name
@export var attack_points := 0: set = _set_atk
@export var defense_points := 0: set = _set_def
@export var special_points := 0: set = _set_spec
@export var heal_points := 0: set = _set_heal
@export var range_points := 0: set = _set_range
@export var miss := false: set = _set_miss


func _set_percent(val):
	percent_of_wheel = val
	emit_changed()


func _set_name(val):
	section_name = val
	emit_changed()


func _set_atk(val):
	attack_points = val
	emit_changed()


func _set_def(val):
	defense_points = val
	emit_changed()


func _set_spec(val):
	special_points = val
	emit_changed()


func _set_heal(val):
	heal_points = val
	emit_changed()


func _set_range(val):
	range_points = val
	emit_changed()


func _set_miss(val):
	miss = val
	emit_changed()
