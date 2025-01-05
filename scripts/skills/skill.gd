extends Node2D

class_name Skill

var skill_def: SkillDef
var hero: Unit

signal skill_finished(result: Variant)


func _has_enough_stamina() -> bool:
	return hero.stamina >= skill_def.stamina_cost


func can_use() -> bool:
	return _has_enough_stamina()


func dispose():
	queue_free()


func use():
	printerr("Skill not implemented ", skill_def.skill_name)
	emit_signal("skill_finished", false)


## Call this from a sub class in the `use()` method override if it
## is a synchronous skill, or if you want to end the skill before any `await` happens.
## Every use override MUST either call this method or emit the `skill_finished` signal itself.
func _end_sync_skill(result: Variant = null):
	call_deferred("emit_signal", "skill_finished", result)
