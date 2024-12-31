@tool
extends Sprite2D

class_name WheelSection

@onready var _pivot = $Pivot
@onready var _section_name = $Pivot/SectionName
@onready var _icon_containers = $Pivot/SectionName/Icons

@export var wheel_section_data: Resource: set = _set_data

@export var sword_icon: Texture2D
@export var shield_icon: Texture2D
@export var lightning_icon: Texture2D
@export var heart_icon: Texture2D
@export var miss_icon: Texture2D


func _ready():
	_update_wheel()


func _set_data(section_data):
	if wheel_section_data:
		wheel_section_data.disconnect("changed", Callable(self, "_update_wheel"))
	wheel_section_data = section_data
	if wheel_section_data:
		wheel_section_data.connect("changed", Callable(self, "_update_wheel"))
		if is_inside_tree():
			_update_wheel()


func _update_wheel():
	if not wheel_section_data or not is_inside_tree():
		return

	_update_name()
	_update_icons()
	_update_visibility()
	_update_positioning()


# =============
#     NAME
# =============
func _update_name():
	if not _section_name:
		_section_name = $Pivot/SectionName
	_section_name.text = wheel_section_data.section_name


# =============
#     ICONS
# =============
func _update_icons():
	if not _icon_containers:
		_icon_containers = $Pivot/SectionName/Icons

	for child in _icon_containers.get_children():
		child.queue_free()

	if wheel_section_data.miss:
		_add_icon_grid(1, miss_icon, "Miss")
	else:
		_add_icon_grid(wheel_section_data.heal_points, heart_icon, "Heal")
		_add_icon_grid(wheel_section_data.attack_points, sword_icon, "Attack")
		_add_icon_grid(wheel_section_data.special_points, lightning_icon, "Special")
		_add_icon_grid(wheel_section_data.defense_points, shield_icon, "Defense")


func _add_icon_grid(amount, texture, name):
	if amount <= 0:
		return

	var max_columns = 4
	var icon_grid := GridContainer.new()
	_icon_containers.add_child(icon_grid)
	icon_grid.name = name
	icon_grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	if amount < max_columns:
		icon_grid.columns = amount
	else:
		if amount / 2 < max_columns:
			icon_grid.columns = amount / 2
		else:
			icon_grid.columns = max_columns

	icon_grid.owner = get_tree().edited_scene_root
	_add_icons(icon_grid, amount, texture, name)


func _add_icons(container, amount, texture, node_prefix = "TexRect"):
	for i in range(0, amount):
		var tex_rect := TextureRect.new()
		tex_rect.texture = texture
		tex_rect.name = node_prefix + "_" + str(i + 1)
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		container.add_child(tex_rect)
		tex_rect.owner = get_tree().edited_scene_root


# =============
#  VISIBILITY
# =============
func _update_visibility():
	material.set_shader_parameter("visible_percent", wheel_section_data.percent_of_wheel)


# =============
#  POSITIONING
# =============
func _update_positioning():
	if not _pivot:
		_pivot = $Pivot

	var default_rotation = PI  # 180 deg
	_pivot.set_rotation(default_rotation * wheel_section_data.percent_of_wheel)

	if wheel_section_data.section_name.is_empty():
		_icon_containers.position.y = 0
	else:
		_icon_containers.position.y = _section_name.size.y
