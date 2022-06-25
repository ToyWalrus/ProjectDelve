tool
extends Node2D

signal clicked
signal entered
signal exited

export(Vector2) var size: Vector2 setget _set_size
export(int, FLAGS, "left", "middle", "right") var button_mask = 1
export(bool) var debug_events := false

var _was_in_bounds_last_frame := false
var _bounds: Rect2


func _ready():
	if debug_events:
		connect("entered", self, "_on_event", ["entered"])
		connect("exited", self, "_on_event", ["exited"])
		connect("clicked", self, "_on_event", ["clicked"])


# https://docs.godotengine.org/en/3.5/tutorials/inputs/input_examples.html#mouse-events
func _unhandled_input(event):
	match event.get_class():
		"InputEventMouseButton":
			var just_pressed = (event as InputEventMouseButton).is_action_pressed("mouse_click")
			var button = event.button_mask
			if just_pressed and _within_bounds(event.position) and button & button_mask > 0:
				emit_signal("clicked", event)
		"InputEventMouseMotion":
			if _within_bounds(event.position):
				if not _was_in_bounds_last_frame:
					emit_signal("entered", event)
				_was_in_bounds_last_frame = true
			elif _was_in_bounds_last_frame:
				emit_signal("exited", event)
				_was_in_bounds_last_frame = false


func _set_size(newVal):
	size = newVal
	_bounds = Rect2(position, size)
	update()


func _within_bounds(position: Vector2):
	return _bounds.has_point(position)


func _draw():
	if Engine.editor_hint:
		var color = Color("#e74322")
		draw_rect(_bounds, color, false)


func _set(property, value):
	match property:
		"position":
			position = value
			_bounds = Rect2(value, size)


func _on_event(ev, name):
	print(ev)
	print(name)
