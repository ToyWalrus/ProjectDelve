extends Node2D

class_name PathDrawer

export(Color) var path_color setget _set_path_color
export(Texture) var arrow_point: Texture setget _set_arrow_point
export(float) var path_thickness := 4.375 setget _set_path_thickness

var _path: PoolVector2Array = []


func draw_path(path: PoolVector2Array, color: Color = Color.transparent, thickness: float = 0):
	_path = path
	if color != Color.transparent:
		path_color = color
	if thickness != 0:
		path_thickness = thickness
	update()


func erase_path():
	_path = []
	update()


func _set_path_thickness(newVal):
	path_thickness = newVal
	update()


func _set_arrow_point(newVal):
	arrow_point = newVal
	update()


func _set_path_color(newVal):
	path_color = newVal
	update()


func _draw():
	if _path.empty():
		return

	var last_dir := Vector2.UP
	for idx in range(1, _path.size()):
		var from = _path[idx - 1]
		var to = _path[idx]
		last_dir = from.direction_to(to)

		if idx == _path.size() - 1:
			to = lerp(from, to, .75)

		draw_line(from, to, path_color, path_thickness)

	if arrow_point:
		var scale = 8.0
		var scale_size = Vector2(1.0 / scale, 1.0 / scale)
		var arrow_size = arrow_point.get_size()

		var final_loc = _path[-1]

		var offset = last_dir * arrow_size
		offset += last_dir.rotated(-PI / 2.0) * arrow_size / 2.0
		offset -= last_dir * arrow_size / 2.0

		draw_set_transform(final_loc + offset * scale_size, last_dir.angle() + PI / 2.0, scale_size)

		draw_texture(arrow_point, Vector2.ZERO, path_color)
