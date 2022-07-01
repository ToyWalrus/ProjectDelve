shader_type canvas_item;

uniform int total_segments = 4;
uniform int current_segments = 4;
uniform vec4 bar_color : hint_color = vec4(.51, .15, .64, 1);
uniform vec4 shadow_color : hint_color = vec4(.25, .25, .25, 1);

float get_section_size() {
	return 1.0 / float(total_segments * 2 - 1);
}

bool should_draw_segment(float size, float start) {
	int section = int(floor(start / size));
	bool is_draw_section = section % 2 == 0;
	
	if (!is_draw_section) {
		return false;
	}
	
	if (current_segments < total_segments) {
		start = start * float(total_segments);
		return start < float(current_segments);
	}
	
	return true;
}

void fragment() {
	float sec_size = get_section_size();
	float shadow_cutoff = 1.0 - 1.0 / 3.0;
	
	if (should_draw_segment(sec_size, UV.x)) {
		if (UV.y < shadow_cutoff) {
			COLOR = bar_color;
		} else {
			COLOR = shadow_color;
		}
	} else {
		COLOR = vec4(0, 0, 0, 0);
	}
}