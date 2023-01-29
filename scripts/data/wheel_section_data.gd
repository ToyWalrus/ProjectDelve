tool
extends Resource

class_name WheelSectionData

export(float, 0, 1) var percent_of_wheel := 1.0 setget _set_percent
export(String) var section_name = "" setget _set_name
export(int) var attack_points := 0 setget _set_atk
export(int) var defense_points := 0 setget _set_def
export(int) var special_points := 0 setget _set_spec
export(int) var heal_points := 0 setget _set_heal
export(int) var range_points := 0 setget _set_range
export(bool) var miss := false setget _set_miss


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
