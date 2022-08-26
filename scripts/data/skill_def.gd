extends Resource

class_name SkillDef

export(String) var skill_script_path := "res://scripts/skills/skill.gd"
export(String) var skill_name
export(String) var skill_description
export(bool) var is_action
export(bool) var is_interrupt
export(int) var uses_per_round := -1
export(int) var stamina_cost
export(int) var experience_cost


func get_skill(hero_ref) -> Node2D:
	var skill_node := Node2D.new()
	skill_node.name = skill_name
	skill_node.script = load(skill_script_path)
	skill_node.hero = hero_ref
	skill_node.skill_def = self
	return skill_node
