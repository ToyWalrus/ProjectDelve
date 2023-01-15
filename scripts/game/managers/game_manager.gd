extends Node

signal unit_died(unit)
signal unit_spawned(unit, location)
signal item_collected(item)

var _hero_quest: Quest
var _overlord_quest: Quest


func set_hero_quest(quest: Quest):
	_hero_quest = quest
	_hero_quest.begin_tracking()


func set_overlord_quest(quest: Quest):
	_overlord_quest = quest
	_overlord_quest.begin_tracking()
