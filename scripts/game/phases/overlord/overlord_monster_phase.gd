extends State

class_name OverlordMonsterPhase

var monster_groups: Array
var _have_finished_turn: Array
var _current_monster_group
var _turn_gui


func _init(sm: StateMachine).(sm, "OverlordMonsterPhase"):
	_have_finished_turn = []
	_turn_gui = GUIManager.get_unit_turn_gui()


func enter_state():
	.enter_state()
	monster_groups = _parent.get_tree().get_nodes_in_group("monster_group")
	_select_next_monster_group()


func _monster_group_completed():
	_have_finished_turn.append(_current_monster_group)
	if _have_finished_turn.size() == monster_groups.size():
		_change_state(OverlordEndPhase.new(_parent))
	else:
		_select_next_monster_group()


var counter := -1


func _select_next_monster_group():
	_turn_gui.set_header_text("Select monster group...")

	return monster_groups[counter]


func _start_monster_group_turn(group):
	_current_monster_group = group
	var sub_phase = MonsterGroupPhase.new(_state_machine, group.get_children())
	sub_phase.connect("monster_group_completed", self, "_monster_group_completed")
	_state_machine.change_state(sub_phase)
