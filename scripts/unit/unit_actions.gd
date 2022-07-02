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
signal unit_selected


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


# ====================


func set_active_dungeon(dungeon):
	_active_dungeon = dungeon


func select_action(action):
	var action_func

	match action:
		Action.move:
			action_func = do_move_action()
		Action.attack:
			action_func = do_attack_action()
		Action.rest:
			action_func = do_rest_action()
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


# =================
#      ACTIONS
# =================
func do_move_action():
	var unit = yield(_wait_until_unit_selected(), "completed")
	print("Waiting for destination selection...")

	_active_dungeon.connect("grid_tile_hovered", self, "_highlight_path", [unit])
	unit.toggle_highlight(true, null, true)

	var completed = false
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
			if unit.can_move_to(position, pathfinder, true):
				unit.toggle_highlight(false)
				yield(unit.move_to(position, pathfinder), "completed")
				completed = true
			else:
				print("Not a valid tile selection")

	_active_dungeon.erase_path()
	_active_dungeon.disconnect("grid_tile_hovered", self, "_highlight_path")


func do_attack_action():
	# Set up highlighter and connect listener to unit hovered
	var unit = yield(_wait_until_unit_selected(Color.red, true, 4.0), "completed")
	var dmg = 2
	if unit:
		dmg = unit.take_damage(dmg)
		unit.toggle_highlight(false)
		print(unit.name + " took " + str(dmg) + " damage")


func do_rest_action():
	var unit = yield(_wait_until_unit_selected(), "completed")
	if unit:
		unit.rest()
		unit.toggle_highlight(false)
		print(unit.name + " rested and recovered all stamina")


# ==================
#      HELPERS
# ==================
func _get_all_units():
	return get_tree().get_nodes_in_group("units")


func _select_unit(event, unit):
	_disconnect_unit_signals()
	print("Unit selected: " + unit.name)
	emit_signal("unit_selected", unit)


func _wait_until_unit_selected(highlight_color = null, fade = false, fade_frequency = 0):
	print("Waiting for unit selection...")

	var units = _get_all_units()
	for unit in units:
		unit.connect("clicked", self, "_select_unit", [unit])
		unit.connect("entered", self, "_highlight_unit", [unit, true, highlight_color, fade, fade_frequency])
		unit.connect("exited", self, "_highlight_unit", [unit, false])

	var unit = yield(self, "unit_selected")
	return unit


func _highlight_unit(event, unit, highlighted, color = null, fade = false, fade_frequency = 0):
	unit.toggle_highlight(highlighted, color, fade, fade_frequency)


func _highlight_path(event, loc, pathfinder, unit):
	var color = Color("#12f957")

	var path = unit.path_to(loc, pathfinder)
	var can_move_to = unit.can_move_to(loc, pathfinder)

	if not can_move_to:
		color = Color("#e8a948")
		var can_move_to_with_stamina = unit.can_move_to(loc, pathfinder, true)
		if not can_move_to_with_stamina:
			return

	_active_dungeon.draw_path(path, color)


func _disconnect_unit_signals():
	var units = _get_all_units()
	for unit in units:
		unit.disconnect("clicked", self, "_select_unit")
		unit.disconnect("entered", self, "_highlight_unit")
		unit.disconnect("exited", self, "_highlight_unit")
