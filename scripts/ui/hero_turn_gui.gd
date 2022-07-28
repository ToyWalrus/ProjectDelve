extends CanvasLayer

class_name HeroTurnGUI

signal button_pressed

onready var _backdrop = $Backdrop
onready var _btn_move = $Backdrop/ButtonGrid/Move
onready var _btn_move_extra = $Backdrop/ButtonGrid/MoveExtra
onready var _btn_attack = $Backdrop/ButtonGrid/Attack
onready var _btn_skill = $Backdrop/ButtonGrid/Skill
onready var _btn_interact = $Backdrop/ButtonGrid/Interact
onready var _btn_rest = $Backdrop/ButtonGrid/Rest
onready var _btn_revive = $Backdrop/ButtonGrid/Revive
onready var _btn_stand = $Backdrop/ButtonGrid/StandUp
onready var _btn_end = $Backdrop/ButtonGrid/EndTurn
onready var _hero_name = $HeroName
onready var _tween = $Tween
onready var _avatar_list = $HeroAvatars
onready var _avatar_scene: PackedScene = preload("res://scenes/CharacterAvatar.tscn")

var _btn_map: Dictionary
var _backdrop_visible_pos: Vector2
var _backdrop_hidden_pos: Vector2
var _hero_list: Array


func _ready():
	set_meta("gui_type", "hero")

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


func set_hero_list(heroes: Array):
	_hero_list = heroes
	var avatars = []
	for hero in heroes:
		if not hero:
			continue
		var avatar = _avatar_scene.instance()
		avatar.name = hero.name
		avatar.character_sprite = hero.unit_data.sprite
		avatars.append(avatar)
	_avatar_list.set_avatar_list(avatars, true)


func set_current_hero(hero: Unit):
	if _hero_list.has(hero):
		_hero_name.text = hero.name
		_avatar_list.set_active_avatar_index(_hero_list.find(hero))
	else:
		_avatar_list.set_active_avatar_index(-1)


func show_gui(anim_duration := .75):
	_animate_backdrop(_backdrop_hidden_pos, _backdrop_visible_pos, anim_duration)


func hide_gui(anim_duration := .75):
	_animate_backdrop(_backdrop_visible_pos, _backdrop_hidden_pos, anim_duration)


func enable_buttons(action_list: Array, hide_disabled_buttons = false):
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
					or action == HeroActionPhase.Actions.stand
					or action == HeroActionPhase.Actions.move_extra
				)
				else true
			)


func _animate_backdrop(from: Vector2, to: Vector2, anim_duration: float):
	_tween.interpolate_property(_backdrop, "rect_position", from, to, anim_duration, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	_tween.start()


func _connect_buttons():
	for key in _btn_map.keys():
		_btn_map[key].connect("pressed", self, "emit_signal", ["button_pressed", key])
