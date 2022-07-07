extends Node

class_name DataParser

func parse_unit_data(path) -> UnitData:
	var parser := XMLParser.new()
	parser.open(path)
	
	var unit_data := UnitData.new()

	while parser.read() != ERR_FILE_EOF:
		match parser.get_node_type():
			XMLParser.NODE_ELEMENT:
				_parse_basic_tree(parser, parser.get_node_name(), unit_data, funcref(self, "_set_from_text_node"))

	print("Done!")
	return unit_data

func _parse_basic_tree(parser, parent_node_name: String, unit_data: UnitData, lambda: FuncRef):
	print("Parsing parent node " + parent_node_name)
	var node_name
	while true:
		parser.read()
		match parser.get_node_type():
			XMLParser.NODE_ELEMENT_END:
				if parser.get_node_name() == parent_node_name:
					return
			XMLParser.NODE_ELEMENT:
				node_name = parser.get_node_name()
				if node_name == "Defense":
					print("Parsing defense")
					unit_data.defense = _read_wheel_data(parser)
				if node_name == "Size":
					var x = parser.get_named_attribute_value("x")
					var y = parser.get_named_attribute_value("y")
					unit_data.size = Vector2(x, y)
					print("Setting size " + str(Vector2(x,y)))
			XMLParser.NODE_TEXT:
				var node_data := parser.get_node_data() as String
				if not _is_only_whitespace(node_data):
					lambda.call_func(parser, unit_data, node_name, node_data)

func _set_from_text_node(parser, unit_data, current_stat, node_data):
	match current_stat:
		"Sprite":
			unit_data.sprite = load(node_data)
		"Health":
			unit_data.health = int(node_data)
		"Speed":
			unit_data.speed = int(node_data)
		"Stamina":
			unit_data.stamina = int(node_data)
		"Strength":
			unit_data.strength = int(node_data)
		"Knowledge":
			unit_data.knowledge = int(node_data)
		"Insight":
			unit_data.insight = int(node_data)
		"Perception":
			unit_data.perception = int(node_data)
		_:
			print("Unmatched stat: " + current_stat)
			return
	print("Just set " + current_stat + ": " + node_data)


func _read_wheel_data(parser):
	var data_sections = []
	while true:
		parser.read()
		if parser.get_node_type() == XMLParser.NODE_ELEMENT_END and parser.get_node_name() == "Wheel":
			return data_sections
			
		if parser.get_node_type() == XMLParser.NODE_ELEMENT and parser.get_node_name() == "WheelSection":	
			var data := WheelSectionData.new()

			var percent := float(parser.get_named_attribute_value("percent"))
			var atk = parser.get_named_attribute_value_safe("attack")
			var def = parser.get_named_attribute_value_safe("defense")
			var spec = parser.get_named_attribute_value_safe("special")
			var heal = parser.get_named_attribute_value_safe("health")
			var miss = parser.get_named_attribute_value_safe("miss")

			data.percent_of_wheel = percent

			if not miss.empty():
				data.miss = true
			else:
				if not atk.empty():
					data.attack_points = int(atk)
				if not def.empty():
					data.defense_points = int(def)
				if not spec.empty():
					data.special_points = int(spec)
				if not heal.empty():
					data.heal_points = int(heal)

			data_sections.append(data)
		

func _is_only_whitespace(string_to_check: String) -> bool:
	var regex := RegEx.new()
	regex.compile("^\\s*$")
	return regex.search(string_to_check) != null
