tool
extends Sprite

class_name WheelSection

onready var _icon_container = $SectionName/Icons
onready var _section_name = $SectionName

export(Resource) var wheel_section_data setget _set_data

export(Texture) var sword_icon
export(Texture) var shield_icon
export(Texture) var lightning_icon
export(Texture) var miss_icon


func _set_data(section_data):
	wheel_section_data = section_data
	_update_wheel()


func _update_wheel():
	if not wheel_section_data or not has_node("SectionName/Icons"):
		return
	if not _icon_container:
		_icon_container = $SectionName/Icons

	for child in _icon_container.get_children():
		child.queue_free()

	if wheel_section_data.miss:
		_add_icons(1, miss_icon, "Miss")
	else:
		_add_icons(wheel_section_data.attack_points, sword_icon, "Sword")
		_add_icons(wheel_section_data.special_points, lightning_icon, "Lightning")
		_add_icons(wheel_section_data.defense_points, shield_icon, "Shield")


func _add_icons(amount, texture, node_prefix = "TexRect"):
	for i in range(0, amount):
		var tex_rect := TextureRect.new()
		tex_rect.texture = texture
		tex_rect.name = node_prefix + "_" + str(i + 1)
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		_icon_container.add_child(tex_rect)
		tex_rect.owner = get_tree().edited_scene_root
