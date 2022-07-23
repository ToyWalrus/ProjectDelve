tool
extends CanvasItem

export(float) var default_avatar_size := 34.0 setget _set_default_avatar_size
export(int) var active_avatar_index := -1 setget set_active_avatar_index
export(Array) var avatars setget _set_avatar_list


func _ready():
	_update_avatar_list()


func set_active_avatar_index(index: int):
	active_avatar_index = index
	_update_avatar_list()


func _set_avatar_list(newVal):
	avatars = newVal
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

		var avatar = (avatars[i] as PackedScene).instance()
		avatar.name = "Avatar " + str(i + 1)
		add_child(avatar)
		avatar.owner = root
		(avatar as Control).rect_min_size = Vector2(size, size)


func _clear_old_list():
	for child in get_children():
		remove_child(child)
		child.queue_free()