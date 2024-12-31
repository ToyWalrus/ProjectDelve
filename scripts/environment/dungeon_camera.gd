extends Camera2D
class_name DungeonCamera

@export var zoom_step := .1 # (float, .05, 1)
@export var max_zoom := 1.5
@export var min_zoom := .1


func screen_to_world_point(point: Vector2) -> Vector2:
	return point * zoom + get_camera_position()


# Returns the camera position at top left corner
func get_camera_position():
	var screen_size = get_viewport_rect().size * zoom
	return position - screen_size * .5


func _unhandled_input(event):
	if event.is_class("InputEventMouseButton") and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_clamp_zoom(false)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_clamp_zoom(true)


func _clamp_zoom(zooming_in):
	var step = zoom_step if zooming_in else -zoom_step
	var x = clamp(zoom.x + step, min_zoom, max_zoom)
	var y = clamp(zoom.y + step, min_zoom, max_zoom)
	zoom = Vector2(x, y)
