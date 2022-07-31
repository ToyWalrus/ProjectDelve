extends State

signal monster_group_completed

class_name MonsterGroupPhase

var monsters: Array
var _have_finished_turn: Array
var _current_monster: Unit
var _turn_gui


func _init(sm: StateMachine, units: Array).(sm, "MonsterGroupPhase"):
	_state_machine.connect("changed_state", self, "_on_sub_state_machine_change_state")
	monsters = units
	_have_finished_turn = []
	_turn_gui = GUIManager.get_unit_turn_gui()
	_turn_gui.set_avatar_list(monsters)


func enter_state():
	.enter_state()
	_turn_gui.set_visible(true)
	_select_next_monster()


func _on_sub_state_machine_change_state(new_state_name: String):
	if new_state_name == "MonsterEndPhase":
		_have_finished_turn.append(_current_monster)

		if _have_finished_turn.size() == monsters.size():
			_turn_gui.set_visible(false)
			emit_signal("monster_group_completed")
		else:
			_select_next_monster()


var counter := -1


func _select_next_monster():
	_turn_gui.set_header_text("Select monster...")
	Utils.connect_signal(_turn_gui, "avatar_clicked", self, "_start_monster_turn", [], CONNECT_ONESHOT)
	_turn_gui.grayscale_avatars(_have_finished_turn)
	_turn_gui.enable_avatar_selection(_have_finished_turn)


func _start_monster_turn(monster: Unit):
	_current_monster = monster
	_turn_gui.disable_avatar_selection()
	_state_machine.change_state(MonsterStartPhase.new(_state_machine, monster))
