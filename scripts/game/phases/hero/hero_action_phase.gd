extends State

class_name HeroActionPhase

var hero: Unit
var action_points: int
var leftover_movement: int
var _turn_gui


func _init(sm: StateMachine, unit: Unit).(sm, "HeroActionPhase"):
	hero = unit
	action_points = 2
	leftover_movement = 0
	_turn_gui = GUIManager.get_unit_turn_gui()


func enter_state():
	.enter_state()
	_select_action()


func _select_action():
	_turn_gui.enable_buttons(_get_available_actions())
	_turn_gui.show_gui()
	_turn_gui.connect("button_pressed", self, "_action_selected", [], CONNECT_ONESHOT)


func _action_selected(action):
	var ap_used := 1
	_turn_gui.hide_gui()

	match action:
		UnitActions.Actions.end_turn:
			_change_state(HeroEndPhase.new(_parent, hero))
			return
		UnitActions.Actions.stand:
			yield(UnitActions.do_stand_up_action(hero), "completed")
			ap_used = 2
		UnitActions.Actions.move:
			hero.toggle_highlight(true, Color.white, true, 2)
			var cost = yield(UnitActions.do_move_action(hero, true), "completed")
			if cost == -1:
				ap_used = 0
			else:
				leftover_movement = hero.unit_data.speed - cost
		UnitActions.Actions.move_extra:
			hero.toggle_highlight(true, Color.white, true, 2)
			var cost = yield(UnitActions.do_move_action(hero, false, leftover_movement), "completed")
			ap_used = 0
			if cost > 0:
				leftover_movement -= cost
		UnitActions.Actions.rest:
			yield(UnitActions.do_rest_action(hero), "completed")
			ap_used = 2
		UnitActions.Actions.skill:
			yield(UnitActions.do_skill_action(hero, hero.skills[0]), "completed")
		UnitActions.Actions.attack:
			var did_attack = yield(UnitActions.do_attack_action(hero, "monsters"), "completed")
			if not did_attack:
				ap_used = 0
		UnitActions.Actions.interact:
			yield(UnitActions.do_interact_action(hero), "completed")
		UnitActions.Actions.revive:
			var did_revive = yield(UnitActions.do_revive_action(hero), "completed")
			if not did_revive:
				ap_used = 0

	hero.toggle_highlight(true, Color.white, false)
	action_points -= ap_used
	_select_action()


func _get_available_actions():
	var available = [UnitActions.Actions.end_turn]
	if action_points <= 0:
		if leftover_movement > 0 and UnitActions.can_do_move_action(hero):
			available.append(UnitActions.Actions.move_extra)
	elif UnitActions.can_do_stand_up_action(hero):
		available = [UnitActions.Actions.stand]
	else:
		if UnitActions.can_do_attack_action(hero, null):
			available.append(UnitActions.Actions.attack)
		if UnitActions.can_do_move_action(hero):
			available.append(UnitActions.Actions.move)
		if UnitActions.can_do_rest_action(hero):
			available.append(UnitActions.Actions.rest)
		if UnitActions.can_do_interact_action(hero):
			available.append(UnitActions.Actions.interact)
		if UnitActions.can_do_skill_action(hero, hero.skills[0]):
			available.append(UnitActions.Actions.skill)
		if UnitActions.can_do_revive_action(hero):
			available.append(UnitActions.Actions.revive)

	return available
