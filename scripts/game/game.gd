extends Node

export(Resource) var hero_quest
export(Resource) var overlord_quest

onready var _phase_manager = $PhaseManager


func _ready():
	GameManager.set_hero_quest(hero_quest)
	GameManager.set_overlord_quest(overlord_quest)
	_phase_manager.call_deferred("start_hero_turn")
