tool
extends Node2D

class_name MouseListener

signal clicked
signal entered
signal exited

export(bool) var debug_mouse_events := false
export(Rect2) var bounds: Rect2 setget _set_bounds
export(int, FLAGS, "left", "middle", "right") var button_mask = 1

var _was_in_bounds_last_frame := false
var _draw_bounds: Rect2


func _ready():
	_update_draw_bounds()
	if debug_mouse_events:
		print("debuggin")
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


func _set_bounds(newVal):
	bounds = newVal
	_update_draw_bounds()
	update()


func _within_bounds(position: Vector2):
	var offset_bounds = Rect2(_draw_bounds)
	offset_bounds.position += self.position
	return offset_bounds.has_point(position)


func _draw():
	if Engine.editor_hint or debug_mouse_events:
		var color = Color("#e74322")
		draw_rect(_draw_bounds, color, false)


func _set(property, value):
	match property:
		"position":
			position = value
			bounds.position = value
			_update_draw_bounds()


func _update_draw_bounds():
	_draw_bounds = Rect2(bounds)
	_draw_bounds.position = bounds.position - bounds.size / 2


func _on_event(ev, name):
	print(ev)
	print(name)
