extends CanvasLayer

class_name UnitSkillList

signal button_pressed

onready var _backdrop = $Backdrop
onready var _button_grid = $Backdrop/ButtonGrid
onready var _btn_skill_1 = $Backdrop/ButtonGrid/Skill_1
onready var _btn_skill_2 = $Backdrop/ButtonGrid/Skill_2
onready var _btn_skill_3 = $Backdrop/ButtonGrid/Skill_3
onready var _btn_skill_4 = $Backdrop/ButtonGrid/Skill_4
onready var _btn_skill_5 = $Backdrop/ButtonGrid/Skill_5
onready var _btn_skill_6 = $Backdrop/ButtonGrid/Skill_6
onready var _btn_skill_7 = $Backdrop/ButtonGrid/Skill_7
onready var _btn_cancel = $Backdrop/ButtonGrid/Cancel
onready var _tween = $Tween

var _btns: Array
var _skill_list: Array
var _backdrop_visible_pos: Vector2
var _backdrop_hidden_pos: Vector2


func _ready():
	_btns = [
		_btn_skill_1,
		_btn_skill_2,
		_btn_skill_3,
		_btn_skill_4,
		_btn_skill_5,
		_btn_skill_6,
		_btn_skill_7,
	]

	_backdrop_hidden_pos = _backdrop.rect_position
	_backdrop_visible_pos = _backdrop_hidden_pos + Vector2(_backdrop.rect_size.x, 0)
	_connect_buttons()


func show_gui(anim_duration := .75):
	_animate_backdrop(_backdrop_hidden_pos, _backdrop_visible_pos, anim_duration)


func hide_gui(anim_duration := .75):
	_animate_backdrop(_backdrop_visible_pos, _backdrop_hidden_pos, anim_duration)


func set_skills(list: Array, disabled_indices = []):
	for btn in _btns:
		btn.visible = false

	for idx in range(list.size()):
		var btn = _btns[idx]
		var skill_def = list[idx]

		btn.visible = true
		btn.disabled = disabled_indices.has(idx)
		btn.text = skill_def.skill_name


func _animate_backdrop(from: Vector2, to: Vector2, anim_duration: float):
	_tween.interpolate_property(_backdrop, "rect_position", from, to, anim_duration, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	_tween.start()


func _connect_buttons():
	for idx in range(_btns.size()):
		Utils.connect_signal(_btns[idx], "pressed", self, "_btn_pressed", [idx])
	Utils.connect_signal(_btn_cancel, "pressed", self, "_btn_pressed", [null])


func _btn_pressed(index):
	emit_signal("button_pressed", index)
