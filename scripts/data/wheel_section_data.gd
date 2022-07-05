extends Resource

class_name WheelSectionData

export(float, 0, 1) var percent_of_wheel
export(String) var section_name
export(int) var attack_points
export(int) var defense_points
export(int) var special_points
export(int, 0, 6) var range_points
export(bool) var miss

enum WheelSymbol { attack, defense, special, miss, range_2, range_3, range_4, range_5, range_6 }
