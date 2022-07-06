extends Node2D

onready var wheel = $Wheel


func _on_stop():
	wheel.stop_wheel()


func _on_spin():
	wheel.spin_wheel()


func _wheel_landed(section: WheelSectionData):
	print("Wheel landed on section: " + ("miss" if section.miss else ("attack " + str(section.attack_points))))
