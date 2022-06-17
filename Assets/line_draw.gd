extends Node2D

var path: PoolVector2Array setget set_path


func set_path(p):
	path = p
	update()


func _draw():
	if path:
		print("drawing...")
		print(path)
		draw_polyline(path, Color.whitesmoke, 3, true)
