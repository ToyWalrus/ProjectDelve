extends State

class_name OverlordMonsterPhase

var monster_groups: Array
var _have_finished_activation: Array
var _current_monster_group
var _monster_group_gui


func _init(sm: StateMachine).(sm, "OverlordMonsterPhase"):
	_have_finished_activation = []
	_monster_group_gui = GUIManager.get_avatar_selection_gui()


func enter_state():
	.enter_state()
	monster_groups = _parent.get_tree().get_nodes_in_group("monster_group")
	_monster_group_gui.set_visible(true)
	_select_next_monster_group()


func _monster_group_completed():
	_have_finished_activation.append(_current_monster_group)
	if _have_finished_activation.size() == monster_groups.size():
		_change_state(OverlordEndPhase.new(_parent))
	else:
		_select_next_monster_group()


func _select_next_monster_group():
	_monster_group_gui.set_header_text("Select monster group...")
	_monster_group_gui.set_avatar_list(monster_groups, true)
	_monster_group_gui.grayscale_avatars(_have_finished_activation)
	Utils.connect_signal(_monster_group_gui, "avatar_clicked", self, "_start_monster_group_turn", [], CONNECT_ONESHOT)
	_monster_group_gui.enable_avatar_selection(_have_finished_activation)


func _start_monster_group_turn(group):
	_current_monster_group = group
	_monster_group_gui.disable_avatar_selection()
	var sub_phase = MonsterGroupPhase.new(_state_machine, group.get_children())
	sub_phase.connect("monster_group_completed", self, "_monster_group_completed")
	_state_machine.change_state(sub_phase)
