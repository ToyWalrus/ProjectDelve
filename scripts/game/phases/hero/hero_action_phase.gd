extends State

class_name HeroActionPhase

enum Actions { move, rest, skill, attack, interact, revive, stand, move_extra, end_turn }

var hero: Unit
var action_points: int
var leftover_movement: int


func _init(sm: StateMachine, unit: Unit).(sm, "HeroActionPhase"):
	hero = unit
	action_points = 2
	leftover_movement = 0


func enter_state():
	.enter_state()
	_select_action()


func _select_action():
	pass


func _get_available_actions():
	var available = [Actions.end_turn]
	if action_points <= 0:
		if leftover_movement > 0:
			available.append(Actions.move_extra)
	elif hero.hp <= 0:
		available = [Actions.stand]
	else:
		available.append_array([Actions.move, Actions.rest])

	return available


func _action_selected(action):
	var ap_used := 1

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
