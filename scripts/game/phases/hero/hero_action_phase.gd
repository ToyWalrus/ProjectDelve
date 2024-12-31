extends State

class_name HeroActionPhase

var hero: Unit
var action_points: int
var leftover_movement: int
var _turn_gui
var _skill_gui


func _init(sm: StateMachine, unit: Unit):
	super(sm, "HeroActionPhase")
	hero = unit
	action_points = 2
	leftover_movement = 0
	_turn_gui = GUIManager.get_unit_turn_gui()
	_skill_gui = GUIManager.get_skill_list_gui()


func enter_state():
	super.enter_state()
	_select_action()


func _select_action():
	_turn_gui.enable_buttons(_get_available_actions())
	_turn_gui.show_gui()
	_turn_gui.connect("button_pressed", Callable(self, "_action_selected").bind(), CONNECT_ONE_SHOT)


func _action_selected(action):
	var ap_used := 1
	_turn_gui.hide_gui()

	match action:
		UnitActions.Actions.end_turn:
			_change_state(HeroEndPhase.new(_parent, hero))
			return
		UnitActions.Actions.stand:
			await UnitActions.do_stand_up_action(hero)
			ap_used = 2
		UnitActions.Actions.move:
			hero.toggle_highlight(true, Color.WHITE, true, 2)
			var cost = await UnitActions.do_move_action(hero, true)
			if cost == -1:
				ap_used = 0
			else:
				leftover_movement = hero.unit_data.speed - cost
		UnitActions.Actions.move_extra:
			hero.toggle_highlight(true, Color.WHITE, true, 2)
			var cost = await UnitActions.do_move_action(hero, false, leftover_movement)
			ap_used = 0
			if cost > 0:
				leftover_movement -= cost
		UnitActions.Actions.rest:
			await UnitActions.do_rest_action(hero)
			ap_used = 2
		UnitActions.Actions.skill:
			var used_skill = await _open_skill_list()
			if not used_skill:
				ap_used = 0
		UnitActions.Actions.attack:
			var did_attack = await UnitActions.do_attack_action(hero, "monsters")
			if not did_attack:
				ap_used = 0
		UnitActions.Actions.interact:
			await UnitActions.do_interact_action(hero)
		UnitActions.Actions.revive:
			var did_revive = await UnitActions.do_revive_action(hero)
			if not did_revive:
				ap_used = 0

	hero.toggle_highlight(true, Color.WHITE, false)
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
		if UnitActions.can_do_attack_action(hero):
			available.append(UnitActions.Actions.attack)
		if UnitActions.can_do_move_action(hero):
			available.append(UnitActions.Actions.move)
		if UnitActions.can_do_rest_action(hero):
			available.append(UnitActions.Actions.rest)
		if UnitActions.can_do_interact_action(hero):
			available.append(UnitActions.Actions.interact)
		if hero.skills:
			available.append(UnitActions.Actions.skill)
		if UnitActions.can_do_revive_action(hero):
			available.append(UnitActions.Actions.revive)

	return available


func _open_skill_list():
	var disabled_skills = []
	for idx in range(hero.skills.size()):
		var skill = hero.skills[idx]
		if not UnitActions.can_do_skill_action(hero, skill):
			disabled_skills.append(idx)

	_skill_gui.set_skills(hero.skills, disabled_skills)
	_skill_gui.show_gui()

	var skill_index = await _skill_gui.button_pressed

	_skill_gui.hide_gui()

	if skill_index == null:
		return false

	await UnitActions.do_skill_action(hero, hero.skills[skill_index])

	return true
