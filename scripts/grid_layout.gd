extends TileMap

class_name GridLayout

var bounds: Rect2


func _ready():
	bounds = get_used_rect()


func _input(event):
	if event.is_class("InputEventMouseButton") and (event as InputEventMouseButton).is_pressed():
		_on_grid_click(event)


func _on_grid_click(event: InputEventMouseButton):
	var _tileCoord = world_to_map(event.position)
	print(_tileCoord)
	# gets atlas coordinate of tile
	# get_cell_autotile_coord(_tileCoord.x, _tileCoord.y)
