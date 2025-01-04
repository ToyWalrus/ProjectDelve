@tool
extends Node2D

class_name Wheel

signal wheel_stopped

@export var wheel_section: PackedScene
@export var wheel_sections: Array:
	set = _set_wheel_sections
@export var stopping_time := 1.0  # (float, .1, 2)
@export var startup_time := 1.0  # (float, .1, 2)

@onready var _sections_container = $Sections

var _wheel_started := false
var _wheel_spinning := false
var _startup_final_rot := 360.0
var _prev_deg := 0.0
var _deg_delta
var _tween: Tween


func _ready():
	randomize()
	_draw_wheel()


func spin_wheel():
	if _wheel_started:
		return
	_wheel_started = true

	var actual_rot = _sections_container.rotation_degrees
	var current_rot = int(actual_rot) % 360 + (actual_rot - int(actual_rot))
	_startup_final_rot = current_rot + 360 * -1

	if _tween:
		_tween.kill()

	_tween = create_tween().set_parallel()

	# Parallel 1
	(
		_tween
		. tween_property(_sections_container, "rotation_degrees", _startup_final_rot, startup_time)
		. from(current_rot)
		. set_trans(Tween.TRANS_QUINT)
		. set_ease(Tween.EASE_IN)
	)

	# Parallel 2
	(
		_tween
		. tween_method(_set_deg_delta, current_rot, _startup_final_rot, startup_time)
		. set_trans(Tween.TRANS_QUINT)
		. set_ease(Tween.EASE_IN)
	)

	await get_tree().create_timer(startup_time).timeout

	_wheel_spinning = true


func stop_wheel():
	if not _wheel_spinning:
		emit_signal("wheel_stopped", null)
		return
	_wheel_spinning = false

	var current_rot = _sections_container.rotation_degrees
	var rand_value = randf_range(0, 1.0)

	# Get current rotation at 0 degrees
	var ending_rot = current_rot - int(current_rot) % 360

	# Set end value to within 360 degrees
	ending_rot -= rand_value * 360

	# Spin 2 extra times before stopping
	ending_rot -= 360 * 2

	if _tween:
		_tween.kill()

	_tween = create_tween()
	(
		_tween
		. tween_property(_sections_container, "rotation_degrees", ending_rot, stopping_time)
		. from(current_rot)
		. set_trans(Tween.TRANS_SINE)
		. set_ease(Tween.EASE_OUT)
	)

	await get_tree().create_timer(stopping_time).timeout

	_wheel_started = false
	emit_signal("wheel_stopped", get_section_at(rand_value))


func get_section_at(percent):
	var offset := 0.0
	for section in wheel_sections:
		if percent <= section.percent_of_wheel + offset:
			return section
		offset += section.percent_of_wheel


func _process(_delta):
	if Engine.is_editor_hint() or not is_inside_tree() or not _wheel_spinning:
		return

	_sections_container.rotate(deg_to_rad(_deg_delta))


func _set_deg_delta(current_deg):
	if current_deg == _startup_final_rot:
		return
	_deg_delta = current_deg - _prev_deg
	_prev_deg = current_deg


func _draw_wheel():
	if not wheel_section or not is_inside_tree():
		return

	for child in _sections_container.get_children():
		child.queue_free()

	var adjustment = _get_section_adjustment()
	var root = get_tree().edited_scene_root

	var current_offset := 0
	for section_data in wheel_sections:
		var scene = wheel_section.instantiate()
		scene.set_meta("_edit_lock_", true)
		_sections_container.add_child(scene)
		scene.owner = root
		scene.wheel_section_data = section_data
		if adjustment != 0:
			scene.wheel_section_data.percent_of_wheel += adjustment
		scene.rotate(deg_to_rad(current_offset))
		current_offset += scene.wheel_section_data.percent_of_wheel * 360.0


func _get_section_adjustment():
	if wheel_sections.is_empty():
		return 1

	var total := 0.0
	for section in wheel_sections:
		total += section.percent_of_wheel

	var remaining = 1.0 - total
	return remaining / float(wheel_sections.size())


func _set_wheel_sections(sections):
	wheel_sections = sections
	_draw_wheel()
