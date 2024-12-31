extends Resource

class_name SkillDef

@export var skill_script_path := "res://scripts/skills/skill.gd"
@export var skill_name: String
@export var skill_description: String
@export var is_action: bool
@export var is_interrupt: bool
@export var always_available: bool
@export var uses_per_round := -1
@export var stamina_cost: int
@export var experience_cost: int


func get_skill(hero_ref) -> Node2D:
	var skill_node := Node2D.new()
	skill_node.name = skill_name
	skill_node.script = load(skill_script_path)
	skill_node.hero = hero_ref
	skill_node.skill_def = self
	return skill_node
