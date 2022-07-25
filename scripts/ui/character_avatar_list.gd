tool
extends CanvasItem

export(float) var default_avatar_size := 34.0 setget _set_default_avatar_size
export(int) var active_avatar_index := -1 setget set_active_avatar_index
export(Array) var avatars setget set_avatar_list

var _avatars_already_instanced: bool


func _ready():
	_update_avatar_list()


func set_active_avatar_index(index: int):
	active_avatar_index = index
	_update_avatar_list()


func set_avatar_list(newVal, items_are_instanced = false):
	avatars = newVal
	_avatars_already_instanced = items_are_instanced
	_clear_old_list(true)
	_update_avatar_list()


func _set_default_avatar_size(newVal):
	default_avatar_size = newVal
	_update_avatar_list()


func _update_avatar_list():
	_clear_old_list()
	active_avatar_index = int(clamp(active_avatar_index, -1, avatars.size() - 1))

	var root
	if Engine.editor_hint and is_inside_tree():
		root = get_tree().edited_scene_root

	for i in range(avatars.size()):
		if not avatars[i]:
			continue

		var size = default_avatar_size
		if i == active_avatar_index:
			size *= 1.5

		var avatar = avatars[i] if _avatars_already_instanced else avatars[i].instance()
		add_child(avatar)
		if root:
			avatar.owner = root
		avatar.set_avatar_size(Vector2(size, size))


func _clear_old_list(force = false):
	if Engine.editor_hint or force:
		for child in get_children():
			remove_child(child)
			child.queue_free()
