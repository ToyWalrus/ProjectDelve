tool
extends ColorRect

signal clicked

export(Texture) var character_sprite setget _set_sprite
export(Vector2) var offset setget _set_offset
export(Vector2) var scale setget _set_scale
export(Color) var background_color setget _set_background_color
export(Color) var border_color setget _set_border_color
export(float, 0.0, 1.0) var border_size setget _set_border_size
export(bool) var grayscale setget _set_grayscale

var _original_shader_params := {}


func _init():
	_set_original_shader_params()


func _ready():
	_update_shader_params()
	connect("gui_input", self, "_on_gui_input")


func set_avatar_size(new_size: Vector2, anim_duration := .5):
	var current_size = rect_min_size
	$Tween.interpolate_property(
		self, "rect_min_size", current_size, new_size, anim_duration, Tween.TRANS_EXPO, Tween.EASE_IN_OUT
	)
	$Tween.start()


func _set_sprite(newVal):
	character_sprite = newVal
	if newVal:
		var size = newVal.get_size()
		offset = SIZE_TO_OFFSET[size]
		scale = SIZE_TO_SCALE[size]
	_update_shader_params()


func _set_scale(newVal):
	scale = newVal
	_update_shader_params()


func _set_offset(newVal):
	offset = newVal
	_update_shader_params()


func _set_background_color(newVal):
	if not newVal:
		background_color = _original_shader_params["background_color"]
	else:
		background_color = newVal
	_update_shader_params()


func _set_border_color(newVal):
	if not newVal:
		border_color = _original_shader_params["border_color"]
	else:
		border_color = newVal
	_update_shader_params()


func _set_border_size(newVal):
	border_size = newVal
	_update_shader_params()


func _set_grayscale(newVal):
	grayscale = newVal
	_update_shader_params()


func _update_shader_params():
	material.set_shader_param("sprite", character_sprite)
	material.set_shader_param("sprite_scale", scale)
	material.set_shader_param("sprite_offset", offset)
	material.set_shader_param("background_color", background_color)
	material.set_shader_param("border_color", border_color)
	material.set_shader_param("border_size", border_size)
	material.set_shader_param("grayscale", grayscale)


func _set_original_shader_params():
	_original_shader_params = {
		"character_sprite": material.get_shader_param("sprite"),
		"offset": material.get_shader_param("sprite_offset"),
		"scale": material.get_shader_param("sprite_scale"),
		"background_color": material.get_shader_param("background_color"),
		"border_color": material.get_shader_param("border_color"),
		"border_size": material.get_shader_param("border_size"),
		"grayscale": material.get_shader_param("grayscale")
	}


func _on_gui_input(event):
	if event.is_class("InputEventMouseButton") and event.is_pressed():
		emit_signal("clicked")


# Ideally the finalized character sprites will all have the same dimensions
# so that this isn't necessary
const SIZE_TO_OFFSET := {
	Vector2(16, 28): Vector2(.5, 3),
	Vector2(16, 24): Vector2(.5, -.7),
	Vector2(16, 20): Vector2(.5, .25),
	Vector2(16, 16): Vector2(.5, .5),
	Vector2(32, 32): Vector2(.5, .1),
	Vector2(32, 34): Vector2(.5, -.25),
	Vector2(32, 36): Vector2(.5, -.5),
}

const SIZE_TO_SCALE := {
	Vector2(16, 28): Vector2(.6, .6),
	Vector2(16, 24): Vector2(.6, .6),
	Vector2(16, 20): Vector2(.6, .6),
	Vector2(16, 16): Vector2(.6, .6),
	Vector2(32, 32): Vector2(.8, .8),
	Vector2(32, 34): Vector2(.8, .8),
	Vector2(32, 36): Vector2(.8, .8),
}
