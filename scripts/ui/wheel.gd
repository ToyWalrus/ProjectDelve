tool
extends Node2D

export(PackedScene) var wheel_section
export(Array) var wheel_sections


func _ready():
	_draw_wheel()


func _draw_wheel():
	if not wheel_section or not is_inside_tree():
		return

	for child in get_children():
		child.queue_free()

	var adjustment = _get_section_adjustment()
	var root = get_tree().edited_scene_root

	var current_offset := 0
	for section_data in wheel_sections:
		var scene = wheel_section.instance()
		add_child(scene)
		scene.owner = root
		scene.wheel_section_data = section_data
		if adjustment != 0:
			scene.wheel_section_data.percent_of_wheel += adjustment
		scene.rotate(deg2rad(current_offset))
		current_offset += scene.wheel_section_data.percent_of_wheel * 360.0


func _get_section_adjustment():
	if wheel_sections.empty():
		return 1

	var total := 0.0
	for section in wheel_sections:
		total += section.percent_of_wheel

	var remaining = 1.0 - total
	return remaining / float(wheel_sections.size())
