extends Node

signal completed

class_name Quest

enum QuestType { kill, collect }

export(QuestType) var type := QuestType.kill
export(int) var amount := 0
export(Array) var objective_groups := []

var _current_count := 0


func begin_tracking():
	_current_count = 0


func _on_unit_killed(unit: Unit):
	if type != QuestType.kill:
		return

	var valid := false
	for group in objective_groups:
		if unit.is_in_group(group):
			valid = true
			break

	if valid:
		_update_count(1)


func _update_count(increase_by: int):
	_current_count += increase_by
	_check_objective_fulfilled()


func _check_objective_fulfilled():
	if _current_count >= amount:
		emit_signal("completed", self)
