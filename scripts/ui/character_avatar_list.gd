@tool
extends CanvasItem

class_name CharacterAvatarList

@export var default_avatar_size := 34.0:
	set = _set_default_avatar_size
@export var active_avatar_index := -1:
	set = set_active_avatar_index
@export var avatars: Array:
	set = _set_avatar_list_internal

var _avatars_already_instanced: bool = false


func _ready():
	if Engine.is_editor_hint():
		_update_avatar_list()


func set_active_avatar_index(index: int):
	active_avatar_index = int(clamp(index, -1, avatars.size() - 1))
	_update_avatar_list()


func _set_avatar_list_internal(newVal: Array):
	avatars = newVal
	_update_avatar_list(true)


func set_avatar_list(newVal: Array, items_are_instanced = false):
	_avatars_already_instanced = items_are_instanced
	avatars = newVal


func _set_default_avatar_size(newVal):
	default_avatar_size = newVal
	_update_avatar_list()


func _update_avatar_list(force_clear_old = false):
	_clear_old_list(force_clear_old)

	var root
	if Engine.is_editor_hint() and is_inside_tree():
		root = get_tree().edited_scene_root

	for i in range(avatars.size()):
		if not avatars[i]:
			continue

		var size = default_avatar_size
		if i == active_avatar_index:
			size *= 1.5

		var avatar = avatars[i] if _avatars_already_instanced else avatars[i].instantiate()

		if not avatar.get_parent():
			add_child(avatar)

		if root:
			avatar.owner = root

		if Engine.is_editor_hint():
			avatar.custom_minimum_size = Vector2(size, size)
		else:
			avatar.set_avatar_size(Vector2(size, size))


func _clear_old_list(force = false):
	if Engine.is_editor_hint() or force:
		for child in get_children():
			remove_child(child)
			child.queue_free()
