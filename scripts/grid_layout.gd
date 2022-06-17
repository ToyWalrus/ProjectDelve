extends TileMap

onready var pathfinder: Pathfinder = $Pathfinder
var pt1
var pt2


func _ready():
	pathfinder.set_tilemap(self)


func _input(event):
	if event.is_class("InputEventMouseButton") and (event as InputEventMouseButton).is_pressed():
		_on_grid_click(event)


func _on_grid_click(event: InputEventMouseButton):
	if not pt1:
		pt1 = event.position
	elif not pt2:
		pt2 = event.position

	if pt1 and pt2:
		$PathDrawer.path = pathfinder.find_path(pt1, pt2)
