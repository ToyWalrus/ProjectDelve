tool
extends MouseListener

class_name Highlightable

var _sprite
var _original_shader_params = {}


func _ready():
	if not _sprite:
		var chillins = get_children()
		for child in chillins:
			if child.is_class("Sprite"):
				_sprite = child
				break

	if _sprite:
		_original_shader_params = {
			"color": _sprite.material.get_shader_param("color"),
			"fade_frequency": _sprite.material.get_shader_param("fade_frequency"),
		}


func toggle_highlight(
	highlighted: bool, color = null, fade = false, fade_frequency = 0, inset = false
):
	_sprite.material.set_shader_param("draw", highlighted)
	_sprite.material.set_shader_param("fade", fade)
	_sprite.material.set_shader_param("inset", inset)

	if color:
		_sprite.material.set_shader_param("color", color)
	else:
		_sprite.material.set_shader_param("color", _original_shader_params["color"])

	if fade_frequency > 0:
		_sprite.material.set_shader_param("fade_frequency", fade_frequency)
	else:
		_sprite.material.set_shader_param(
			"fade_frequency", _original_shader_params["fade_frequency"]
		)
