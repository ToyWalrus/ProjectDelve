tool
extends ColorRect

signal clicked
signal entered
signal exited

export(Texture) var character_sprite setget _set_sprite
export(Vector2) var offset setget _set_offset
export(Vector2) var scale setget _set_scale
export(Color) var background_color setget _set_background_color
export(Color) var border_color setget _set_border_color
export(float, 0.0, 1.0) var border_size setget _set_border_size


func _ready():
	_update_shader_params()
	connect("mouse_entered", self, "emit_signal", ["entered"])
	connect("mouse_exited", self, "emit_signal", ["exited"])
	connect("gui_input", self, "_on_gui_input")


func set_avatar_size(new_size: Vector2, anim_duration := .5):
	var current_size = rect_min_size
	$Tween.interpolate_property(
		self, "rect_min_size", current_size, new_size, anim_duration, Tween.TRANS_EXPO, Tween.EASE_IN_OUT
	)
	$Tween.start()


func _set_sprite(newVal):
	character_sprite = newVal
	_update_shader_params()


func _set_scale(newVal):
	scale = newVal
	_update_shader_params()


func _set_offset(newVal):
	offset = newVal
	_update_shader_params()


func _set_background_color(newVal):
	background_color = newVal
	_update_shader_params()


func _set_border_color(newVal):
	border_color = newVal
	_update_shader_params()


func _set_border_size(newVal):
	border_size = newVal
	_update_shader_params()


func _update_shader_params():
	material.set_shader_param("sprite", character_sprite)
	material.set_shader_param("sprite_scale", scale)
	material.set_shader_param("sprite_offset", offset)
	material.set_shader_param("background_color", background_color)
	material.set_shader_param("border_color", border_color)
	material.set_shader_param("border_size", border_size)


func _on_gui_input(event):
	if event.is_class("InputEventMouseButton") and event.is_pressed():
		emit_signal("clicked")
