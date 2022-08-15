extends Node2D


func _ready():
	call_deferred("_startup")


func _startup():
	# GUIManager.get_unit_turn_gui().set_visible(false)
	# $PhaseManager.start_overlord_turn_debug()
	$PhaseManager.start_hero_turn()


func start_select_tile(opt1 = null, opt2 = null):
	Utils.connect_signal(SelectionManager, "grid_tile_selected", self, "_selected", [], CONNECT_ONESHOT)
	if opt1 and opt2:
		SelectionManager.select_grid_tile([opt1, opt2])
	else:
		SelectionManager.select_grid_tile()


func _selected(grid_coord):
	print("Selected " + str(grid_coord))
