extends Node

signal unit_died(unit)
signal unit_spawned(unit, location)
signal item_collected(item)

var _hero_quest: Quest
var _overlord_quest: Quest


func set_hero_quest(quest: Quest):
	_hero_quest = quest
	Utils.connect_signal(_hero_quest, "completed", self, "_end_game", [true], CONNECT_ONESHOT)
	_hero_quest.begin_tracking()


func set_overlord_quest(quest: Quest):
	_overlord_quest = quest
	Utils.connect_signal(_overlord_quest, "completed", self, "_end_game", [false], CONNECT_ONESHOT)
	_overlord_quest.begin_tracking()


func _end_game(quest, was_hero_quest: bool):
	var who = "hero" if was_hero_quest else "overlord"
	print("Game over, " + who + " player wins!")
