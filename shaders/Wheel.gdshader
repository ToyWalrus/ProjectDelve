shader_type canvas_item;

const float PI = 3.1415926535;
uniform vec4 wheel_color : hint_color = vec4(.33, .61, .97, 1);
uniform vec4 border_color : hint_color = vec4(1, 1, 1, 1);
uniform float visible_percent : hint_range(0, 1) = 1.0;

bool is_border(vec4 color) {
	if (color.r != 0.0 || color.b != 0.0) return false;
	return color.g >= 0.98 && color.a == 1.0;
}

bool should_draw(vec2 uv) {
	if (visible_percent == 1.0) return true;
	if (visible_percent == 0.0) return false;
	
	float start_angle = 0.0;
	float end_angle = visible_percent * PI;
	
	// center of circle at (0.5, 0.5)
	vec2 local_uv = uv - vec2(0.5, 0.5);
	if (distance(vec2(0.0, 0.0), local_uv) > 1.0) {
		return false;
	}
	
	float cutoff_ang = atan(cos(end_angle), sin(end_angle)) * 2.0;
	float point_ang = atan(local_uv.x, local_uv.y);
	
	return point_ang >= cutoff_ang;
}

void fragment() {
	if (!should_draw(UV)) {
		COLOR.a = 0.0;
		return;
	}
	
	COLOR = texture(TEXTURE, UV);
	if (is_border(COLOR)) {
		COLOR = border_color;
	} else if (COLOR.a == 1.0) {
		COLOR *= vec4(wheel_color.r, wheel_color.g, wheel_color.b, 1.0);
	} else {
		COLOR = vec4(border_color.r, border_color.g, border_color.b, COLOR.a);
	}
}