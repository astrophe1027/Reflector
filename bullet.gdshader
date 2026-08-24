shader_type canvas_item;

uniform vec4 line_color : source_color = vec4(1.0, 1.0, 0.0, 1.0); // 테두리 색상
uniform float line_thickness : hint_range(0.0, 10.0) = 2.0;       // 테두리 두께 (픽셀)

void fragment() {
	// Screen UV 미분값을 활용해 경계선과의 거리를 픽셀 단위로 측정
	vec2 dx = dFdx(UV);
	vec2 dy = dFdy(UV);
	float edge = max(length(dx), length(dy));
	
	// 경계면 계산
	float alpha = smoothstep(0.0, edge * line_thickness, min(UV.x, min(UV.y, min(1.0 - UV.x, 1.0 - UV.y))));
	
	// 외곽선 부분만 line_color 적용, 안쪽은 원래 Polygon 색상 사용
	COLOR = mix(line_color, COLOR, alpha);
}