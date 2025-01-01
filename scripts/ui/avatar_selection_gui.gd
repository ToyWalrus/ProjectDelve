extends CanvasLayer

class_name AvatarSelectionGUI

signal avatar_clicked(unit: Unit)

@onready var _header_text: Label = $HeaderText
@onready var _avatar_list: CharacterAvatarList = $CharacterAvatarList
@onready var _avatar_scene: PackedScene = preload("res://scenes/CharacterAvatar.tscn")

var _unit_list: Array

const LINKED_UNIT_GROUP_KEY = "linked_units"
const LINKED_UNIT_KEY = "linked_unit"


func set_gui_visible(is_avatar_selection_visible: bool):
	_header_text.visible = is_avatar_selection_visible
	_avatar_list.visible = is_avatar_selection_visible


func set_avatar_list(units, is_unit_group = false):
	_unit_list = units

	var avatars := []
	for unit in units:
		if not unit or (is_unit_group and unit.get_children().size() == 0):
			continue
		var avatar = _avatar_scene.instantiate()
		avatar.name = unit.name

		var meta_key
		if is_unit_group:
			avatar.character_sprite = unit.get_children()[0].unit_data.sprite
			meta_key = LINKED_UNIT_GROUP_KEY
		else:
			avatar.character_sprite = unit.unit_data.sprite
			meta_key = LINKED_UNIT_KEY

		avatar.set_meta(meta_key, unit)
		avatars.append(avatar)

	_avatar_list.set_avatar_list(avatars, true)


func set_header_text(text):
	if not text or text.is_empty():
		_header_text.visible = false
	else:
		_header_text.text = text
		_header_text.visible = true


func set_current_unit(unit):
	if _unit_list.has(unit):
		set_header_text(unit.name)
		_avatar_list.set_active_avatar_index(_unit_list.find(unit))
	else:
		_avatar_list.set_active_avatar_index(-1)
		set_header_text(null)


func enable_avatar_selection(disabled_options = []):
	for i in range(_avatar_list.avatars.size()):
		if disabled_options.has(_unit_list[i]):
			continue
		var avatar = _avatar_list.avatars[i]
		Utils.connect_signal(avatar, "clicked", self, "_on_clicked_avatar", [avatar])
		Utils.connect_signal(avatar, "mouse_entered", self, "_on_hover_over_avatar", [avatar, true])
		Utils.connect_signal(avatar, "mouse_exited", self, "_on_hover_over_avatar", [avatar, false])


func disable_avatar_selection():
	for avatar in _avatar_list.avatars:
		Utils.disconnect_signal(avatar, "clicked", self, "_on_clicked_avatar")
		Utils.disconnect_signal(avatar, "mouse_entered", self, "_on_hover_over_avatar")
		Utils.disconnect_signal(avatar, "mouse_exited", self, "_on_hover_over_avatar")


func grayscale_avatars(list):
	for i in range(_avatar_list.avatars.size()):
		var avatar = _avatar_list.avatars[i]
		if list.has(_unit_list[i]):
			avatar.grayscale = true
		else:
			avatar.grayscale = false


func _on_clicked_avatar(avatar):
	avatar.border_color = Color.BLACK

	var selected
	if avatar.has_meta(LINKED_UNIT_KEY):
		selected = avatar.get_meta(LINKED_UNIT_KEY)
		selected.toggle_highlight(false)
	elif avatar.has_meta(LINKED_UNIT_GROUP_KEY):
		selected = avatar.get_meta(LINKED_UNIT_GROUP_KEY)
		for node in selected.get_children():
			node.toggle_highlight(false)

	emit_signal("avatar_clicked", selected)


func _on_hover_over_avatar(avatar, entering):
	if entering:
		avatar.border_color = Color.WHITE
		if avatar.has_meta(LINKED_UNIT_KEY):
			avatar.get_meta(LINKED_UNIT_KEY).toggle_highlight(true, Color.WHITE, true, 3)
		elif avatar.has_meta(LINKED_UNIT_GROUP_KEY):
			for node in avatar.get_meta(LINKED_UNIT_GROUP_KEY).get_children():
				node.toggle_highlight(true, Color.WHITE, true, 3)
	else:
		avatar.border_color = Color.BLACK
		if avatar.has_meta(LINKED_UNIT_KEY):
			avatar.get_meta(LINKED_UNIT_KEY).toggle_highlight(false)
		elif avatar.has_meta(LINKED_UNIT_GROUP_KEY):
			for node in avatar.get_meta(LINKED_UNIT_GROUP_KEY).get_children():
				node.toggle_highlight(false)
