extends Node

class_name State

signal state_entered
signal state_exited

var state_name: String = ""
var _parent: StateMachine
var _state_machine: StateMachine


func _init(owning_state_machine: StateMachine, name_of_state: String = ""):
	state_name = name if name_of_state.empty() else name_of_state
	name = state_name
	_parent = owning_state_machine
	_state_machine = StateMachine.new()
	add_child(_state_machine)


func enter_state():
	emit_signal("state_entered")


func exit_state():
	emit_signal("state_exited")
	queue_free()


func _change_state(next_state: State):
	_parent.change_state(next_state)
