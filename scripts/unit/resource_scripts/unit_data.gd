tool
extends Resource

class_name UnitData

export(Texture) var sprite = null setget _set_sprite
export(Vector2) var size := Vector2.ONE

export(int) var health := 0
export(int) var speed := 0
export(int) var defense := 0  # will change type eventually
export(int) var attack := 0  # will change type eventually

export(int, -1, 5) var strength := -1
export(int, -1, 5) var insight := -1
export(int, -1, 5) var perception := -1
export(int, -1, 5) var knowledge := -1
export(int) var stamina := -1


func _set_sprite(new_sprite):
	sprite = new_sprite
	var scene = get_local_scene()
	if scene != null and scene.has_node("Sprite"):
		var sprite_node = scene.get_node("Sprite")
		sprite_node.texture = new_sprite
