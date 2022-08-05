tool
extends Resource

class_name UnitData

export(Texture) var sprite: Texture setget _set_sprite
export(Vector2) var size := Vector2.ONE

export(int) var health := 0
export(int) var speed := 0
export(Array) var defense = []

export(int, -1, 5) var strength := -1
export(int, -1, 5) var insight := -1
export(int, -1, 5) var perception := -1
export(int, -1, 5) var knowledge := -1
export(int) var stamina := 0 setget _set_stamina


func _set_sprite(new_sprite):
	sprite = new_sprite
	var unit = get_meta("unit")
	if unit and unit.has_node("Sprite"):
		var sprite_node = unit.get_node("Sprite")
		sprite_node.texture = new_sprite


func _set_stamina(new_stamina):
	stamina = new_stamina
	var unit = get_meta("unit")
	if unit:
		unit.stamina = new_stamina
