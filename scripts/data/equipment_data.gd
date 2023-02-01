extends Resource

class_name EquipmentData

enum EquipSlots { head, torso, foot, hand }
var HEAD_SLOTS = 1
var TORSO_SLOTS = 1
var FOOT_SLOTS = 1
var HAND_SLOTS = 2

# The name of this equipment
export(String) var name

# Which slot does this equipment belong to
export(EquipSlots) var slot

# How many slots does this equipment take up
export(int) var slot_count := 1

# Arbitrary strings describing the object (e.g. cloak, rune, dagger, etc)
export(PoolStringArray) var attributes := []

# Any actions the equipment provides in addition to base hero actions
export(Array) var extra_actions

# Any actions the equipment provides available with surge points
export(Array) var surge_actions
