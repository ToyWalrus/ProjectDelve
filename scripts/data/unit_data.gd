@tool
extends Resource

class_name UnitData

@export var sprite: Texture2D:
	set = _set_sprite
@export var size := Vector2.ONE

@export var health := 0
@export var speed := 0
@export var defense: Array = []

@export var strength := -1  # (int, -1, 5)
@export var insight := -1  # (int, -1, 5)
@export var perception := -1  # (int, -1, 5)
@export var knowledge := -1  # (int, -1, 5)
@export var stamina := 0:
	set = _set_stamina


func _set_sprite(new_sprite):
	sprite = new_sprite
	var unit = get_meta("unit") if has_meta("unit") else null
	if unit and unit.has_node("Sprite2D"):
		var sprite_node = unit.get_node("Sprite2D")
		sprite_node.texture = new_sprite


func _set_stamina(new_stamina):
	stamina = new_stamina
	var unit = get_meta("unit") if has_meta("unit") else null
	if unit:
		unit.stamina = new_stamina
