extends State

signal monster_group_completed

class_name MonsterGroupPhase

var monsters: Array
var _have_finished_turn: Array
var _current_monster: Unit


func _init(sm: StateMachine, units: Array).(sm, "MonsterGroupPhase"):
	monsters = units
	_have_finished_turn = []
	_state_machine.connect("changed_state", self, "_on_sub_state_machine_change_state")
	GUIManager.get_unit_turn_gui().set_avatar_list(monsters)


func enter_state():
	.enter_state()
	_start_monster_turn(_select_next_monster())


func _on_sub_state_machine_change_state(new_state_name: String):
	if new_state_name == "MonsterEndPhase":
		_have_finished_turn.append(_current_monster)

		if _have_finished_turn.size() == monsters.size():
			emit_signal("monster_group_completed")
		else:
			_start_monster_turn(_select_next_monster())


var counter := -1


func _select_next_monster():
	counter += 1
	return monsters[counter]


func _start_monster_turn(monster: Unit):
	_current_monster = monster
	_state_machine.change_state(MonsterStartPhase.new(_state_machine, monster))
