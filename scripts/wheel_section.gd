tool
extends Sprite

class_name WheelSection

onready var _icon_row_container = $SectionName/IconRows
onready var _section_name = $SectionName

export(Resource) var wheel_section_data setget _set_data

export(Texture) var sword_icon
export(Texture) var shield_icon
export(Texture) var lightning_icon
export(Texture) var miss_icon


func _ready():
	_update_wheel()


func _set_data(section_data):
	if wheel_section_data:
		wheel_section_data.disconnect("changed", self, "_update_wheel")
	wheel_section_data = section_data
	if wheel_section_data:
		wheel_section_data.connect("changed", self, "_update_wheel")


func _update_wheel():
	if not wheel_section_data or not has_node("SectionName/IconRows"):
		return
	if not _icon_row_container:
		_icon_row_container = $SectionName/IconRows

	for child in _icon_row_container.get_children():
		child.queue_free()

	if wheel_section_data.miss:
		_add_icon_row(1, miss_icon, "Miss")
	else:
		_add_icon_row(wheel_section_data.attack_points, sword_icon, "Attack")
		_add_icon_row(wheel_section_data.special_points, lightning_icon, "Special")
		_add_icon_row(wheel_section_data.defense_points, shield_icon, "Defense")


func _add_icon_row(amount, texture, name):
	if amount <= 0:
		return
	var icon_row := HBoxContainer.new()
	icon_row.name = name
	icon_row.alignment = BoxContainer.ALIGN_CENTER
	_icon_row_container.add_child(icon_row)
	icon_row.owner = get_tree().edited_scene_root
	_add_icons(icon_row, amount, texture, name)


func _add_icons(container, amount, texture, node_prefix = "TexRect"):
	for i in range(0, amount):
		var tex_rect := TextureRect.new()
		tex_rect.texture = texture
		tex_rect.name = node_prefix + "_" + str(i + 1)
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		container.add_child(tex_rect)
		tex_rect.owner = get_tree().edited_scene_root
		tex_rect.rect_scale = Vector2(2, 2)
