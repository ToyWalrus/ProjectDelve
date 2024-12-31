@tool
class_name MouseListener

extends Node2D

signal clicked
signal entered
signal exited

@export var debug := false: set = _set_debug
@export var enabled := true
@export var bounds := Vector2.ZERO: set = _set_bounds
@export var button_mask := 1 # (int, FLAGS, "left", "middle", "right")

var _extended_bounds := Vector2.ZERO
var _was_in_bounds_last_frame := false
var _scene_cam: Camera2D


func extend_bounds(size: Vector2):
	_extended_bounds = size
	queue_redraw()


func revert_extended_bounds():
	extend_bounds(Vector2.ZERO)


func _ready():
	connect("entered", Callable(self, "_on_event").bind("entered"))
	connect("exited", Callable(self, "_on_event").bind("exited"))
	connect("clicked", Callable(self, "_on_event").bind("clicked"))


# https://docs.godotengine.org/en/3.5/tutorials/inputs/input_examples.html#mouse-events
func _unhandled_input(event):
	if not enabled:
		return
	match event.get_class():
		"InputEventMouseButton":
			var just_pressed = (event as InputEventMouseButton).is_action_pressed("mouse_click")
			var is_valid_button = event.button_mask & button_mask > 0
			if just_pressed and is_valid_button and _within_bounds(event.position):
				emit_signal("clicked", event)
		"InputEventMouseMotion":
			if _within_bounds(event.position):
				if not _was_in_bounds_last_frame:
					emit_signal("entered", event)
				_was_in_bounds_last_frame = true
			elif _was_in_bounds_last_frame:
				emit_signal("exited", event)
				_was_in_bounds_last_frame = false


func _set_bounds(newVal: Vector2):
	bounds = newVal
	queue_redraw()


func _set_debug(newVal: bool):
	debug = newVal
	queue_redraw()


func _get_offset_bounds() -> Rect2:
	var size = bounds + _extended_bounds
	return Rect2(position - size / 2, size)


func _within_bounds(position: Vector2):
	_check_for_cam()
	if _scene_cam:
		position = _scene_cam.call("screen_to_world_point", position)

	return _get_offset_bounds().has_point(position)


func _draw():
	if debug and enabled:
		var draw_bounds = _get_offset_bounds()
		var color = Color("#e74322")
		draw_rect(Rect2(-draw_bounds.size / 2, draw_bounds.size), color, false, 1.5)


func _on_event(ev, name):
	if debug:
		print("------- DEBUG -------")
		print(name)
		print(ev.position)


func _check_for_cam():
	if _scene_cam:
		return
	var nodes = get_tree().get_nodes_in_group("Camera3D")
	if not nodes.is_empty():
		_scene_cam = nodes[0]
