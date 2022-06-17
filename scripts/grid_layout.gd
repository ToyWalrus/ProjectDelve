extends TileMap

onready var pathfinder: Pathfinder = $Pathfinder
var character: CharacterController

export(PoolStringArray) var obstacle_tile_names = []
export(PoolStringArray) var water_tile_names = []


func _ready():
	(tile_set as DungeonTileset).print_tiles()

	# pathfinder.set_tilemap(self)
	# character = get_parent().get_node("Character")
	# for t in get_used_cells_by_id():
	# 	print(t)


func _input(event):
	if event.is_class("InputEventMouseButton") and (event as InputEventMouseButton).is_pressed():
		var tile_id = get_cellv(world_to_map(event.position))
		print((tile_set as DungeonTileset).is_obstacle_tile(tile_id, obstacle_tile_names))
		# _on_grid_click(event)


func _on_grid_click(event: InputEventMouseButton):
	if not character or character.is_moving:
		return

	character.move_to(event.position)
