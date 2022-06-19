extends Resource

class_name UnitStats

export(Texture) var sprite
export(Vector2) var size
export(int) var speed

# Learning about Resources: https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html


func _init(default_speed = 1, default_size = Vector2.ONE, default_sprite = null):
	speed = default_speed
	size = default_size
	sprite = default_sprite
