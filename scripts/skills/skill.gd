extends Node2D

class_name Skill

var skill_def: SkillDef
var hero: Unit


func _has_enough_stamina() -> bool:
	return hero.stamina >= skill_def.stamina_cost


func can_use() -> bool:
	return _has_enough_stamina()


func dispose():
	queue_free()


func use():
	pass
