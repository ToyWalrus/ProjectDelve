tool
extends Resource

class_name WheelSectionData

export(float, 0, 1) var percent_of_wheel setget _set_percent
export(String) var section_name setget _set_name
export(int) var attack_points setget _set_atk
export(int) var defense_points setget _set_def
export(int) var special_points setget _set_spec
export(int, 0, 6) var range_points setget _set_range
export(bool) var miss setget _set_miss


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


func _set_range(val):
	range_points = val
	emit_changed()


func _set_miss(val):
	miss = val
	emit_changed()
