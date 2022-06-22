tool
extends Resource

class_name UnitStats

export(Vector2) var size
export(int) var speed
export(int) var defense
export(int) var attack
export(int) var health

# Might want to include sprite reference in resource
# to dynamically create characters... if that's even
# needed

# Learning about Resources: https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html


func _init(default_size = Vector2.ONE, default_speed = 1, default_def = 0, default_atk = 0, default_hp = 10):
	size = default_size
	speed = default_speed
	defense = default_def
	attack = default_atk
	health = default_hp
