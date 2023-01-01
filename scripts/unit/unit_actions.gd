extends Node

# https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html

enum Actions { move, rest, skill, attack, interact, revive, stand, move_extra, end_turn }

var _active_dungeon
var _current_action


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
	_start_action(Actions.move)
	DrawManager.enable_path_drawing(unit, can_use_stamina, max_cost)

	var completed = false
	var cost := -1
	while not completed:
		var event_arr = yield(_active_dungeon, "grid_tile_clicked")
		var event = event_arr[0]
		var position = event_arr[1]
		var pathfinder = event_arr[2]

		if not event:
			completed = true
			continue

		if event.button_index == BUTTON_LEFT:
			if unit.can_move_to(position, pathfinder, can_use_stamina, max_cost):
				cost = yield(unit.move_to(position, pathfinder), "completed")
				completed = true

	DrawManager.disable_path_drawing()
	_end_action()
	return cost


func can_do_move_action(unit) -> bool:
	return true


func do_attack_action(unit, target_unit_group = null):
	_start_action(Actions.attack)
	DrawManager.enable_target_drawing(unit, target_unit_group)

	var return_val = false
	var valid_target = false

	while not valid_target:
		SelectionManager.select_member_of_group(target_unit_group, Color.red, true, 4.0)
		var target_unit = yield(SelectionManager, "group_member_selected")

		if not target_unit:
			valid_target = true
			continue

		if target_unit and _active_dungeon.has_line_of_sight_to(unit.position, target_unit.position):
			valid_target = true
			var dmg = 2
			dmg = target_unit.take_damage(dmg)
			target_unit.toggle_highlight(false)
			print(target_unit.name + " took " + str(dmg) + " damage from " + unit.name)
			return_val = true

	DrawManager.disable_target_drawing(target_unit_group)
	_end_action()
	return return_val


func can_do_attack_action(unit, equipped_weapon) -> bool:
	return true


func do_rest_action(unit):
	_start_action(Actions.rest)
	unit.rest()
	print(unit.name + " rested and recovered all stamina")
	yield(get_tree(), "idle_frame")
	_end_action()


func can_do_rest_action(unit) -> bool:
	return true


func do_stand_up_action(unit):
	_start_action(Actions.stand)
	unit.heal(3)
	print(unit.name + " healed 3 and stood up")
	yield(get_tree(), "idle_frame")
	_end_action()


func can_do_stand_up_action(unit) -> bool:
	return unit.hp <= 0


func do_interact_action(unit):
	_start_action(Actions.interact)
	yield(get_tree(), "idle_frame")
	_end_action()


func can_do_interact_action(unit) -> bool:
	var interactables = DungeonManager.get_grid_coordinates_of_group("interactable")
	var unit_pos = DungeonManager.world_to_grid_coordinate(unit.position)
	for interactable_pos in interactables.keys():
		if _is_next_to_in_grid(unit_pos, interactable_pos, true):
			return true
	return false


func do_special_action(unit):
	yield(get_tree(), "idle_frame")


func can_do_special_action(unit) -> bool:
	return false


func do_skill_action(unit, skill_def):
	_start_action(Actions.skill)
	var skill = skill_def.get_skill(unit)
	var result = skill.use()

	yield(Utils.yield_for_result(result), "completed")

	if not skill_def.is_interrupt:
		skill.queue_free()

	_end_action()


func can_do_skill_action(unit, skill_def = null) -> bool:
	if not skill_def:
		return false
	var skill = skill_def.get_skill(unit)
	var can_do = skill.can_use()
	skill.queue_free()
	return can_do


func do_revive_action(unit):
	_start_action(Actions.revive)
	var valid_targets = []
	var heroes = get_tree().get_nodes_in_group("heroes")
	for hero in heroes:
		if hero == unit:
			continue
		if _is_next_to_in_grid(unit.position, hero.position):
			valid_targets.append(hero)

	SelectionManager.select_member_of_group(valid_targets, Color.yellow, true, 1.0)
	var target_unit = yield(SelectionManager, "group_member_selected")
	var return_val = false

	if target_unit:
		target_unit.heal(6)
		print(unit.name + " revived " + target_unit.name + " by recovering 6 health")
		return_val = true

	_end_action()
	return return_val


func can_do_revive_action(unit) -> bool:
	var heroes = DungeonManager.get_grid_coordinates_of_group("heroes")
	var unit_pos = DungeonManager.world_to_grid_coordinate(unit.position)
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


# TODO: move _active_dungeon functions to DungeonManager class
func _is_next_to_in_grid(world_pos_1, world_pos_2, include_same_space = false):
	var dist = _active_dungeon.get_grid_position(world_pos_1).distance_to(
		_active_dungeon.get_grid_position(world_pos_2)
	)
	if include_same_space:
		return dist < 2
	return dist < 2 and dist != 0


func _start_action(action):
	_current_action = action


func _end_action():
	_current_action = null


func _process(delta):
	if not _current_action:
		return

	if Input.is_action_just_pressed("ui_cancel"):
		SelectionManager.cancel_selection()
