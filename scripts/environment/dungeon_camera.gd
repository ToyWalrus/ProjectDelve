extends Camera2D
class_name DungeonCamera

@export var zoom_step := .1  # (float, .05, 1)
@export var max_zoom_out := 2.5
@export var max_zoom_in := 1.2


func screen_to_world_point(screen_point: Vector2):
	var viewport_size = get_viewport_rect().size
	var normalized_point = (screen_point - viewport_size / 2) / zoom
	var world_point = normalized_point + position
	return world_point


func world_to_screen_point(world_point: Vector2):
	var viewport_size = get_viewport_rect().size
	var normalized_point = (world_point - position) / zoom
	var screen_point = normalized_point + viewport_size / 2
	return screen_point


func _unhandled_input(event):
	if event.is_class("InputEventMouseButton") and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_clamp_zoom(false)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_clamp_zoom(true)


func _clamp_zoom(zooming_in):
	var step = zoom_step if zooming_in else -zoom_step
	var new_zoom = clamp(zoom.x + step, max_zoom_in, max_zoom_out)
	zoom = Vector2(new_zoom, new_zoom)
