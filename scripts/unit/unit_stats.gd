tool
extends Resource

class_name UnitStats

export(Vector2) var size
export(int) var speed

# Might want to include sprite reference in resource
# to dynamically create characters... if that's even
# needed

# Learning about Resources: https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html


func _init(default_speed = 1, default_size = Vector2.ONE):
	speed = default_speed
	size = default_size
