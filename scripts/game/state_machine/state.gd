extends Node

class_name State

signal state_entered
signal state_exited

var debug = false
var state_name: String = ""
var _parent: StateMachine
var _state_machine: StateMachine


func _init(owning_state_machine: StateMachine, name_of_state: String = ""):
	state_name = name if name_of_state.empty() else name_of_state
	name = state_name
	_parent = owning_state_machine
	_parent.add_child(self)

	_state_machine = StateMachine.new()
	add_child(_state_machine)


func enter_state():
	_do_print("+ Enter state " + state_name)
	emit_signal("state_entered")


func exit_state():
	_do_print("- Exit state " + state_name)
	_do_print()
	emit_signal("state_exited")
	queue_free()


func _change_state(next_state: State):
	_parent.change_state(next_state)


func _do_print(msg = null):
	if not debug:
		return

	if not msg:
		print()
		return

	var current = _parent
	var prefix = ""
	while current.get_parent():
		prefix += "\t"
		current = current.get_parent()
	print(prefix + msg)
