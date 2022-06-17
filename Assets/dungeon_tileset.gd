extends TileSet

class_name DungeonTileset


func is_obstacle_tile(id: int, obstacle_tile_names: PoolStringArray):
	return tile_get_name(id) in obstacle_tile_names


func is_water_tile(id: int, water_tile_names: PoolStringArray):
	return tile_get_name(id) in water_tile_names


func print_tiles():
	print("Tileset")
	for id in get_tiles_ids():
		print(self.tile_get_name(id))
		# print(self.tile_get_tile_mode(id))
