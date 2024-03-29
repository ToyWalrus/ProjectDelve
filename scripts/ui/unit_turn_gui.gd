extends CanvasLayer

class_name UnitTurnGUI

signal button_pressed

onready var _backdrop = $Backdrop
onready var _button_grid = $Backdrop/ButtonGrid
onready var _btn_move = $Backdrop/ButtonGrid/Move
onready var _btn_move_extra = $Backdrop/ButtonGrid/MoveExtra
onready var _btn_attack = $Backdrop/ButtonGrid/Attack
onready var _btn_skill = $Backdrop/ButtonGrid/Skill
onready var _btn_interact = $Backdrop/ButtonGrid/Interact
onready var _btn_rest = $Backdrop/ButtonGrid/Rest
onready var _btn_revive = $Backdrop/ButtonGrid/Revive
onready var _btn_stand = $Backdrop/ButtonGrid/StandUp
onready var _btn_end = $Backdrop/ButtonGrid/EndTurn
onready var _tween = $Tween

var _btn_map: Dictionary
var _backdrop_visible_pos: Vector2
var _backdrop_hidden_pos: Vector2


func _ready():
	_btn_map = {
		UnitActions.Actions.move: _btn_move,
		UnitActions.Actions.move_extra: _btn_move_extra,
		UnitActions.Actions.attack: _btn_attack,
		UnitActions.Actions.skill: _btn_skill,
		UnitActions.Actions.interact: _btn_interact,
		UnitActions.Actions.rest: _btn_rest,
		UnitActions.Actions.revive: _btn_revive,
		UnitActions.Actions.stand: _btn_stand,
		UnitActions.Actions.end_turn: _btn_end,
	}

	_backdrop_hidden_pos = _backdrop.rect_position
	_backdrop_visible_pos = _backdrop_hidden_pos - Vector2(0, _backdrop.rect_size.y)
	_connect_buttons()


func show_gui(anim_duration := .75):
	_animate_backdrop(_backdrop_hidden_pos, _backdrop_visible_pos, anim_duration)


func hide_gui(anim_duration := .75):
	_animate_backdrop(_backdrop_visible_pos, _backdrop_hidden_pos, anim_duration)


func enable_buttons(action_list: Array, hide_disabled_buttons = false):
	var count = 0
	for action in _btn_map.keys():
		var btn = _btn_map[action]
		if action_list.has(action):
			btn.disabled = false
			btn.visible = true
		else:
			btn.disabled = true
			btn.visible = (
				false
				if (
					hide_disabled_buttons
					or action == UnitActions.Actions.stand
					or action == UnitActions.Actions.move_extra
				)
				else true
			)
		if btn.visible:
			count += 1
	_button_grid.columns = count


func _animate_backdrop(from: Vector2, to: Vector2, anim_duration: float):
	_tween.interpolate_property(_backdrop, "rect_position", from, to, anim_duration, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	_tween.start()


func _connect_buttons():
	for key in _btn_map.keys():
		Utils.connect_signal(_btn_map[key], "pressed", self, "_btn_pressed", [key])


func _btn_pressed(key):
	emit_signal("button_pressed", key)
