extends State

class_name MonsterActionPhase

var monster: Unit
var has_attacked: bool
var action_points: int
var leftover_movement: int
var _monster_gui


func _init(sm: StateMachine, unit: Unit).(sm, "MonsterActionPhase"):
	monster = unit
	has_attacked = false
	action_points = 2
	leftover_movement = 0
	_monster_gui = GUIManager.get_unit_turn_gui()


func enter_state():
	.enter_state()
	_select_action()


func _select_action():
	_monster_gui.enable_buttons(_get_available_actions())
	_monster_gui.show_gui()
	_monster_gui.connect("button_pressed", self, "_action_selected", [], CONNECT_ONESHOT)


func _action_selected(action):
	var ap_used := 1
	_monster_gui.hide_gui()

	match action:
		UnitActions.Actions.end_turn:
			_change_state(MonsterEndPhase.new(_parent, monster))
			return
		UnitActions.Actions.move:
			monster.toggle_highlight(true, Color.white, true, 2)
			var cost = yield(UnitActions.do_move_action(monster, false), "completed")
			if cost == -1:
				ap_used = 0
			else:
				leftover_movement = monster.unit_data.speed - cost
		UnitActions.Actions.move_extra:
			monster.toggle_highlight(true, Color.white, true, 2)
			var cost = yield(UnitActions.do_move_action(monster, false, leftover_movement), "completed")
			ap_used = 0
			if cost > 0:
				leftover_movement -= cost
		UnitActions.Actions.skill:
			yield(UnitActions.do_skill_action(monster, null), "completed")
		UnitActions.Actions.attack:
			has_attacked = yield(UnitActions.do_attack_action(monster, "heroes"), "completed")
			if not has_attacked:
				ap_used = 0
		UnitActions.Actions.interact:
			var did_interact = yield(UnitActions.do_interact_action(monster), "completed")
			if not did_interact:
				ap_used = 0

	monster.toggle_highlight(true, Color.white, false)
	action_points -= ap_used
	_select_action()


func _get_available_actions():
	var available = [UnitActions.Actions.end_turn]
	if action_points <= 0:
		if leftover_movement > 0 and UnitActions.can_do_move_action(monster):
			available.append(UnitActions.Actions.move_extra)
	else:
		if not has_attacked and UnitActions.can_do_attack_action(monster):
			available.append(UnitActions.Actions.attack)
		if UnitActions.can_do_move_action(monster):
			available.append(UnitActions.Actions.move)
		if UnitActions.can_do_interact_action(monster):
			available.append(UnitActions.Actions.interact)
		if UnitActions.can_do_skill_action(monster):
			available.append(UnitActions.Actions.skill)

	return available
