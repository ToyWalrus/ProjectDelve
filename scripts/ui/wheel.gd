tool
extends Node2D

export(PackedScene) var wheel_section
export(Array) var wheel_sections
export(float, .1, 2) var stopping_time := 1.0
export(float, .1, 2) var startup_time := 1.0

onready var _sections_container = $Sections
onready var _tween = $Tween

var _wheel_started := false
var _wheel_spinning := false
var _startup_final_rot := 360.0
var _prev_deg := 0.0
var _deg_delta

signal wheel_stopped


func _ready():
	randomize()
	_draw_wheel()


func spin_wheel():
	if _wheel_started:
		return
	_wheel_started = true

	var actual_rot = _sections_container.rotation_degrees
	var current_rot = int(actual_rot) % 360 + (actual_rot - int(actual_rot))
	_startup_final_rot = current_rot + 360

	_tween.connect("tween_step", self, "_set_delta")

	_tween.interpolate_property(
		_sections_container,
		"rotation_degrees",
		current_rot,
		_startup_final_rot,
		startup_time,
		Tween.TRANS_QUINT,
		Tween.EASE_IN
	)
	_tween.start()

	yield(get_tree().create_timer(startup_time), "timeout")

	_tween.disconnect("tween_step", self, "_set_delta")

	_wheel_spinning = true


func stop_wheel():
	if not _wheel_spinning:
		return
	_wheel_spinning = false

	var current_rot = _sections_container.rotation_degrees
	var rand_value = rand_range(0, 1.0)

	# Get current rotation at 0 degrees
	var ending_rot = current_rot - int(current_rot) % 360

	# Set end value to within 360 degrees
	ending_rot += rand_value * 360

	print("Rand value: " + str(rand_value) + " | Ending rotation: " + str(int(ending_rot) % 360))

	# Spin 3 extra times before stopping
	ending_rot += 360 * 3

	_tween.interpolate_property(
		_sections_container,
		"rotation_degrees",
		current_rot,
		ending_rot,
		stopping_time,
		Tween.TRANS_SINE,
		Tween.EASE_OUT
	)
	_tween.start()

	yield(get_tree().create_timer(stopping_time), "timeout")

	_wheel_started = false
	emit_signal("wheel_stopped", get_section_at(rand_value))


func get_section_at(percent):
	var offset := 0.0
	for section in wheel_sections:
		if percent <= section.percent_of_wheel + offset:
			return section
		offset += section.percent_of_wheel


func _process(delta):
	if Engine.editor_hint or not is_inside_tree() or not _wheel_spinning:
		return

	_sections_container.rotate(deg2rad(_deg_delta))


func _set_delta(obj, key, elapsed, current_deg):
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
		var scene = wheel_section.instance()
		scene.set_meta("_edit_lock_", true)
		_sections_container.add_child(scene)
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
