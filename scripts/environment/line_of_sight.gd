extends Node2D

# I would like to highlight all tiles within line of sight of a unit/tile
# but I think that'll take a little more work to optimize and make viable
# than just determining if tile A is within line of sight of tile B.

# Could pre-bake the vision map if dungeon layout is going to be static.
# The only caveat is that some units will block line of sight and other
# obstacles may appear.

export(bool) var debug = false

var _tile_size
var _draw_from
var _draw_to


func set_tile_size(tile_size):
	_tile_size = tile_size


# Given top left of origin tile and top left of target tile, returns whether there is vision to the space
func can_see(world_point_origin: Vector2, world_point_target: Vector2, extra_obstacles: PoolVector2Array = []):
	for from_world_point in _get_tile_corners(world_point_origin):
		for to_world_point in _get_tile_corners(world_point_target):
			if from_world_point == to_world_point or _has_LoS(from_world_point, to_world_point, extra_obstacles):
				_update_debug(from_world_point, to_world_point)
				return true

	_update_debug(null, null)
	return false


func _has_LoS(from_world_point: Vector2, to_world_point: Vector2, extra_obstacles: PoolVector2Array = []):
	var _from_point = from_world_point
	var _to_point = to_world_point
	# Shape of result:
	# {
	# 	position: Vector2 - point in world space for collision
	# 	normal: Vector2 - normal in world space for collision
	# 	collider: Object - Object collided or null (if unassociated)
	# 	collider_id: ObjectID - Object it collided against
	# 	rid: RID - RID it collided against
	# 	shape: int - shape index of collider
	# 	metadata: Variant() - metadata of collider
	# }
	var result = get_world_2d().direct_space_state.intersect_ray(_from_point, _to_point)
	return result.empty()


func _get_tile_corners(tile):
	if not _tile_size:
		print("Tile size not set -- defaulting to (1, 1)")
		_tile_size = Vector2.ONE
	return PoolVector2Array(
		[
			tile,
			tile + Vector2.RIGHT * _tile_size,
			tile + Vector2.DOWN * _tile_size,
			tile + Vector2.RIGHT * _tile_size + Vector2.DOWN * _tile_size
		]
	)


func _update_debug(from, to):
	_draw_from = from
	_draw_to = to
	update()


func _draw():
	if debug and _draw_from and _draw_to:
		if _draw_from == _draw_to:
			draw_circle(_draw_from, 3, Color.green)
		else:
			draw_line(_draw_from, _draw_to, Color.green, 3)
