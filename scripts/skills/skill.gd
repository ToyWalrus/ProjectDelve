extends Node2D

class_name Skill

var skill_def: SkillDef
var hero: Unit


func can_use():
	return hero.stamina >= skill_def.stamina_cost


func use():
	pass
