extends State

class_name HeroActionPhase

enum Actions { move, rest, skill, attack, interact, revive, stand, move_extra, end_turn }

var hero: Unit
var action_points: int
var leftover_movement: int
var _hero_gui


func _init(sm: StateMachine, unit: Unit).(sm, "HeroActionPhase"):
	hero = unit
	action_points = 2
	leftover_movement = 0


func enter_state():
	.enter_state()

	_hero_gui = GUIManager.get_hero_gui()
	if not _hero_gui:
		printerr('No gui of gui_type "hero" found in current scene!')

	_hero_gui.set_hero_name(hero.name)
	_select_action()


func _select_action():
	_hero_gui.enable_buttons(_get_available_actions())
	_hero_gui.show_gui()
	_hero_gui.connect("button_pressed", self, "_action_selected", [], CONNECT_ONESHOT)


func _action_selected(action):
	var ap_used := 1
	_hero_gui.hide_gui()

	match action:
		Actions.end_turn:
			_change_state(HeroEndPhase.new(_parent))
			return
		Actions.stand:
			yield(UnitActions.do_stand_up_action(hero), "completed")
			ap_used = 2
		Actions.move:
			var cost = yield(UnitActions.do_move_action(hero, true), "completed")
			if cost == -1:
				ap_used = 0
		Actions.move_extra:
			var cost = yield(UnitActions.do_move_action(hero, false, leftover_movement), "completed")
			if cost == -1:
				ap_used = 0
		Actions.rest:
			yield(UnitActions.do_rest_action(hero), "completed")
			ap_used = 2
		Actions.skill:
			yield(UnitActions.do_skill_action(hero, null), "completed")
		Actions.attack:
			yield(UnitActions.do_attack_action(hero, "monsters"), "completed")
		Actions.interact:
			yield(UnitActions.do_interact_action(hero), "completed")
		Actions.revive:
			yield(UnitActions.do_revive_action(hero), "completed")

	action_points -= ap_used
	_select_action()


func _get_available_actions():
	var available = [Actions.end_turn]
	if action_points <= 0:
		if leftover_movement > 0 and UnitActions.can_do_move_action(hero):
			available.append(Actions.move_extra)
	elif UnitActions.can_do_stand_up_action(hero):
		available = [Actions.stand]
	else:
		if UnitActions.can_do_attack_action(hero, null):
			available.append(Actions.attack)
		if UnitActions.can_do_move_action(hero):
			available.append(Actions.move)
		if UnitActions.can_do_rest_action(hero):
			available.append(Actions.rest)
		if UnitActions.can_do_interact_action(hero):
			available.append(Actions.interact)
		if UnitActions.can_do_skill_action(hero):
			available.append(Actions.skill)
		if UnitActions.can_do_revive_action(hero):
			available.append(Actions.revive)

	return available
