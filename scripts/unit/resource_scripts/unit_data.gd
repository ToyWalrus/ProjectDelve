tool
extends Resource

class_name UnitData

export(Texture) var sprite: Texture setget _set_sprite
export(Vector2) var size := Vector2.ONE

export(int) var health := 0
export(int) var speed := 0
export(Array) var defense

export(int, -1, 5) var strength := -1
export(int, -1, 5) var insight := -1
export(int, -1, 5) var perception := -1
export(int, -1, 5) var knowledge := -1
export(int) var stamina := 0 setget _set_stamina


func _set_sprite(new_sprite):
	sprite = new_sprite
	if has_meta("unit"):
		var unit = get_meta("unit")
		for child in unit.get_children():
			if child.is_class("Sprite"):
				child.texture = new_sprite
				return

	var scene = get_local_scene()
	if scene != null and scene.has_node("Sprite"):
		var sprite_node = scene.get_node("Sprite")
		sprite_node.texture = new_sprite


func _set_stamina(new_stamina):
	stamina = new_stamina
	if has_meta("unit"):
		var unit = get_meta("unit")
		unit.stamina = new_stamina
