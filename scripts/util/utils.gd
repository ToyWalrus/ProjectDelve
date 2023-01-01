extends Node


# Connects the signal to the target method, if it isn't already connected and the node has the signal.
# Returns true if operation was successful.
func connect_signal(node, sig, target_object, target_method, binds = [], flags = 0):
	if node.has_signal(sig) and not node.is_connected(sig, target_object, target_method):
		node.connect(sig, target_object, target_method, binds, flags)
		return true
	return false


# Disconnects the signal from the target method, if it was previously connected.
# Returns true if operation was successful.
func disconnect_signal(node, sig, target_object, target_method):
	if node.has_signal(sig) and node.is_connected(sig, target_object, target_method):
		node.disconnect(sig, target_object, target_method)
		return true
	return false


func yield_for_result(result):
	if result is GDScriptFunctionState:
		result = yield(result, "completed")
	else:
		yield(get_tree(), "idle_frame")
	return result
