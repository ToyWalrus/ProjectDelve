extends TileMap

onready var pathfinder: Pathfinder = $Pathfinder
var character: CharacterController


func _ready():
	pathfinder.set_tilemap(self)
	character = get_parent().get_node("Character")


func _input(event):
	if event.is_class("InputEventMouseButton") and (event as InputEventMouseButton).is_pressed():
		_on_grid_click(event)


func _on_grid_click(event: InputEventMouseButton):
	if not character or character.is_moving:
		return

	character.move_to(event.position)
