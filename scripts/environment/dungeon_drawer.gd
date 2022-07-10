extends Node2D

class_name DungeonDrawer

export(Texture) var arrow_point: Texture
export(Color) var path_color: Color
export(float) var path_thickness := 4.375
export(int) var path_z_index := 5

export(Texture) var target: Texture
export(float) var target_line_thickness := 2.0
export(int) var target_z_index := 10

var _path: PoolVector2Array = []
var _target_color: Color
var _target_start
var _target_end


func draw_path(path: PoolVector2Array, color: Color = Color.transparent, thickness: float = 0):
	clear(false)
	z_index = path_z_index
	_path = path
	if color != Color.transparent:
		path_color = color
	if thickness != 0:
		path_thickness = thickness
	update()


func draw_target(from_world_point: Vector2, to_world_point: Vector2, color: Color):
	clear(false)
	z_index = target_z_index
	_target_start = from_world_point
	_target_end = to_world_point
	_target_color = color
	update()


func clear(call_update = true):
	_path = []
	_target_start = null
	_target_end = null
	if call_update:
		update()


func _draw():
	_draw_path()
	_draw_target()


func _draw_path():
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


func _draw_target():
	if not _target_start or not _target_end:
		return

	draw_line(_target_start, _target_end, _target_color, target_line_thickness)

	if target:
		var scale := 6.0
		var scale_size = Vector2(1.0 / scale, 1.0 / scale)
		var offset = -target.get_size() / 2.0

		draw_set_transform(_target_end + offset * scale_size, 0, scale_size)

		draw_texture(target, Vector2.ZERO, _target_color)