extends Node

# https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html

enum Actions { move, rest, skill, attack, interact, revive, stand, move_extra, end_turn }

var _active_dungeon
var _is_performing_action := false

signal action_cancelled


func _input(event):
	if not _is_performing_action:
		return

	if (
		event.is_class("InputEventMouseButton")
		and (event as InputEventMouseButton).is_pressed()
		and (event as InputEventMouseButton).button_index == BUTTON_RIGHT
	):
		emit_signal("action_cancelled")


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
		SelectionManager.wait_until_group_member_selected(target_unit_group, Color.red, true, 4.0), "completed"
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
	yield(get_tree(), "idle_frame")


func can_do_rest_action(unit) -> bool:
	return true


func do_stand_up_action(unit):
	unit.heal(3)
	unit.toggle_highlight(false)
	print(unit.name + " healed 3 and stood up")
	yield(get_tree(), "idle_frame")


func can_do_stand_up_action(unit) -> bool:
	return unit.hp <= 0


func do_interact_action(unit):
	yield(get_tree(), "idle_frame")
	pass


func can_do_interact_action(unit) -> bool:
	var interactables = _active_dungeon.get_grid_coordinates_of_group("interactable")
	var unit_pos = _active_dungeon.get_grid_position(unit.position)
	for interactable_pos in interactables.keys():
		if _is_next_to_in_grid(unit_pos, interactable_pos, true):
			return true
	return false


func do_special_action(unit):
	yield(get_tree(), "idle_frame")
	pass


func can_do_special_action(unit) -> bool:
	return false


func do_skill_action(unit, skill):
	yield(get_tree(), "idle_frame")
	pass


func can_do_skill_action(unit) -> bool:
	return false


func do_revive_action(unit):
	var valid_targets = []
	var heroes = get_tree().get_nodes_in_group("heroes")
	for hero in heroes:
		if hero == unit:
			continue
		if _is_next_to_in_grid(unit.position, hero.position):
			valid_targets.append(hero)

	var target_unit = yield(
		SelectionManager.wait_until_group_member_selected(valid_targets, Color.yellow, true, 1.0), "completed"
	)
	target_unit.heal(6)
	print(unit.name + " revived " + target_unit.name + " by recovering 6 health")


func can_do_revive_action(unit) -> bool:
	var heroes = _active_dungeon.get_grid_coordinates_of_group("heroes")
	var unit_pos = _active_dungeon.get_grid_position(unit.position)
	for hero_pos in heroes.keys():
		var hero = heroes[hero_pos]
		if unit == hero:
			continue
		if hero.hp <= 0 and _is_next_to_in_grid(unit_pos, hero_pos):
			return true
	return false


# ==================
#      HELPERS
# ==================


func _highlight_unit(event, unit, highlighted, color = null, fade = false, fade_frequency = 0):
	unit.toggle_highlight(highlighted, color, fade, fade_frequency)


func _is_next_to_in_grid(world_pos_1, world_pos_2, include_same_space = false):
	var dist = _active_dungeon.get_grid_position(world_pos_1).distance_to(
		_active_dungeon.get_grid_position(world_pos_2)
	)
	if include_same_space:
		return dist < 2
	return dist < 2 and dist != 0
