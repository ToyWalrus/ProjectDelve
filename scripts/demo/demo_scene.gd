extends Node2D


func _ready():
	call_deferred("_startup")


func _startup():
	# GUIManager.get_unit_turn_gui().set_visible(false)
	# $PhaseManager.start_overlord_turn_debug()
	$PhaseManager.start_hero_turn()
