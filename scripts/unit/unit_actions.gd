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


func _ready():
	var debug_buttons = get_tree().get_nodes_in_group("debug_buttons")
	for btn in debug_buttons:
		btn.connect("pressed", self, "_on_debug_button_clicked", [btn.text.to_lower()])


func _on_debug_button_clicked(action_txt):
	if _is_facilitating_action_debug:
		return

	_is_facilitating_action_debug = true
	var unit = get_node("/root/Node2D/Unit")

	var action
	match action_txt:
		"move":
			action = Action.move
		"attack":
			action = Action.attack
		"rest":
			action = Action.rest
		"stand up":
			action = Action.stand_up
		"interact":
			action = Action.interact
		"special":
			action = Action.special

	yield(select_action(unit, action), "completed")
	_is_facilitating_action_debug = false


func set_active_dungeon(dungeon):
	_active_dungeon = dungeon


func select_action(unit, action):
	_active_unit = unit
	var action_func

	match action:
		Action.move:
			action_func = do_move_action()
		Action.attack:
			pass
		Action.rest:
			pass
		Action.stand_up:
			pass
		Action.interact:
			pass
		Action.special:
			pass
		_:
			cancel_action()
			return

	if action_func:
		yield(action_func, "completed")

	emit_signal("action_finished", action)


func cancel_action():
	print("cancel action")
	_active_unit = null
	emit_signal("action_cancelled")


func do_move_action():
	# Set up highlighter and connect listener to grid_tile_hovered

	var completed = false
	while not completed:
		# print("wait for tile clicked...")
		var event_arr = yield(_active_dungeon, "grid_tile_clicked")
		var event = event_arr[0] as InputEventMouseButton
		var pathfinder = event_arr[1]

		if event.button_index == BUTTON_RIGHT:
			# Disable highlighter and disconnect grid_tile_hovered
			cancel_action()
			completed = true

		if event.button_index == BUTTON_LEFT and _active_unit.can_move_to(event.position, pathfinder):
			# Disable highlighter and disconnect grid_tile_hovered
			yield(_active_unit.move_to(event.position, pathfinder), "completed")
			# completed = true

	# print("done")
