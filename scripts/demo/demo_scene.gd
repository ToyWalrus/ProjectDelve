extends Node2D


func _ready():
	call_deferred("_startup")


func _startup():
	$PhaseManager.start_hero_turn()
