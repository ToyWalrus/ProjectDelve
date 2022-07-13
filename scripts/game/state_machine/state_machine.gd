extends Node

class_name StateMachine

# Emits after the next state's enter_state() method is called.
# Passes with parameters: state name
signal changed_state

# The current state
var current: State setget _transition
var _in_transition := false


func change_state(new_state: State):
	_transition(new_state)


func _transition(next_state: State):
	if current == next_state or _in_transition:
		return

	_in_transition = true

	if current != null:
		current.exit_state()

	current = next_state

	if current != null:
		current.enter_state()
		emit_signal("changed_state", current.state_name)
	else:
		emit_signal("changed_state", null)

	_in_transition = false
