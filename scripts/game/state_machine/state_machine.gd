extends Node

class_name StateMachine

# Emits after the next state's enter_state() method is called.
# Passes with parameters: state name
signal changed_state

# The current state
var current setget change_state


func change_state(next_state):
	if current == next_state:
		return

	if current != null:
		current.exit_state()

	current = next_state

	if current != null:
		current.enter_state()
		emit_signal("changed_state", current.state_name)
	else:
		emit_signal("changed_state", null)
