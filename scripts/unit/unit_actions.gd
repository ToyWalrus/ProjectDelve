extends Node

# https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html

enum Action {
	move,
	attack,
	rest,
	stand_up,
	interact,
	special,
}

var _active_unit
var _active_dungeon
var _is_facilitating_action_debug := false

signal action_cancelled
signal action_finished


# ================
#      DEBUG
# ================
func _ready():
	self.connect("action_finished", self, "_on_action_finished_debug")
	var debug_buttons = get_tree().get_nodes_in_group("debug_buttons")
	for btn in debug_buttons:
		btn.connect("pressed", self, "_on_debug_button_clicked", [btn.text.to_lower()])


func _on_action_finished_debug(action):
	print("Action finished")
	print("")


func _on_debug_button_clicked(action_txt):
	if _is_facilitating_action_debug:
		print("Already in the middle of another action!")
		return
	_is_facilitating_action_debug = true

	var action
	match action_txt:
		"move":
			action = Action.move
			print("Selected move action")
		"attack":
			action = Action.attack
			print("Selected attack action")
		"rest":
			action = Action.rest
			print("Selected rest action")
		"stand up":
			action = Action.stand_up
			print("Selected stand up action")
		"interact":
			action = Action.interact
			print("Selected interact action")
		"special":
			action = Action.special
			print("Selected special action")
		_:
			_is_facilitating_action_debug = false
			return

	yield(select_action(action), "completed")
	_is_facilitating_action_debug = false


func select_action(action):
	var action_func

	var unit = yield(SelectionManager.wait_until_unit_selected("units"), "completed")

	match action:
		Action.move:
			action_func = do_move_action(unit)
		Action.attack:
			action_func = do_attack_action(unit)
		Action.rest:
			action_func = do_rest_action(unit)
		Action.stand_up:
			pass
		Action.interact:
			pass
		Action.special:
			pass
		_:
			yield(get_tree(), "idle_frame")
			cancel_action()
			return

	if action_func:
		yield(action_func, "completed")
	else:
		yield(get_tree(), "idle_frame")

	emit_signal("action_finished", action)


func cancel_action():
	print("Action cancelled")
	_active_unit = null
	emit_signal("action_cancelled")


# ====================


func set_active_dungeon(dungeon):
	_active_dungeon = dungeon


# =================
#      ACTIONS
# =================


## Performs a movement action
##
## Given a unit, performs a full move action, including
## checking validity of movement selection. Returns the
## cost of moving to the destination, or -1 if the
## action was cancelled.
func do_move_action(unit, can_use_stamina = false, max_cost = 1000) -> int:
	DrawManager.enable_path_drawing(unit, can_use_stamina, max_cost)
	unit.toggle_highlight(true, null, true)

	var completed = false
	var cost := -1
	while not completed:
		var event_arr = yield(_active_dungeon, "grid_tile_clicked")
		var event = event_arr[0]
		var position = event_arr[1]
		var pathfinder = event_arr[2]

		if event.button_index == BUTTON_RIGHT:
			cancel_action()
			unit.toggle_highlight(false)
			completed = true

		if event.button_index == BUTTON_LEFT:
			if unit.can_move_to(position, pathfinder, can_use_stamina, max_cost):
				unit.toggle_highlight(false)
				cost = yield(unit.move_to(position, pathfinder), "completed")
				completed = true

	DrawManager.disable_path_drawing()
	return cost


func can_do_move_action(unit) -> bool:
	return true


func do_attack_action(unit, target_unit_group = null):
	DrawManager.enable_target_drawing(unit, target_unit_group)

	var target_unit = yield(
		SelectionManager.wait_until_unit_selected(target_unit_group, Color.red, true, 4.0), "completed"
	)
	var dmg = 2
	if target_unit:
		dmg = target_unit.take_damage(dmg)
		target_unit.toggle_highlight(false)
		print(target_unit.name + " took " + str(dmg) + " damage from " + unit.name)

	DrawManager.disable_target_drawing(target_unit_group)


func can_do_attack_action(unit, equipped_weapon) -> bool:
	return true


func do_rest_action(unit):
	unit.rest()
	unit.toggle_highlight(false)
	print(unit.name + " rested and recovered all stamina")


func can_do_rest_action(unit) -> bool:
	return true


func do_stand_up_action(unit):
	unit.heal(3)
	unit.toggle_highlight(false)
	print(unit.name + " healed 3 and stood up")


func can_do_stand_up_action(unit) -> bool:
	return unit.hp <= 0


func do_interact_action(unit):
	pass


func can_do_interact_action(unit) -> bool:
	var interactables = _active_dungeon.get_grid_coordinates_of_group("interactable")
	var unit_pos = _active_dungeon.get_grid_position(unit.position)
	for interactable_pos in interactables.keys():
		if unit_pos.distance_to(interactable_pos) < 2:
			return true
	return false


func do_special_action(unit):
	pass


func can_do_special_action(unit) -> bool:
	return false


func do_skill_action(unit, skill):
	pass


func can_do_skill_action(unit) -> bool:
	return false


func do_revive_action(unit):
	# Check for this, otherwise we may get into a dead state
	if not can_do_revive_action(unit):
		return

	var target_unit = yield(SelectionManager.wait_until_unit_selected("heroes", Color.yellow, true, 1.0), "completed")
	target_unit.heal(6)
	print(unit.name + " revived " + target_unit.name + " by recovering 6 health")


func can_do_revive_action(unit) -> bool:
	var heroes = _active_dungeon.get_grid_coordinates_of_group("heroes")
	var unit_pos = _active_dungeon.get_grid_position(unit.position)
	for hero_pos in heroes.keys():
		var hero = heroes[hero_pos]
		if unit == hero:
			continue
		if hero.hp <= 0 and unit_pos.distance_to(hero_pos) < 2:
			return true
	return false


# ==================
#      HELPERS
# ==================


func _highlight_unit(event, unit, highlighted, color = null, fade = false, fade_frequency = 0):
	unit.toggle_highlight(highlighted, color, fade, fade_frequency)
