shader_type canvas_item;

// ==========================================
// [그룹 1] Curved Line (곡선 휘어짐 설정)
// ==========================================
group_uniforms Curve;
/// 휘어지는 높이 (10.0 ~ 30.0 사이로 조절)
uniform float wave_amplitude : hint_range(0.0, 50.0) = 15.0;
/// 곡선의 파장 길이 (Label 가로 크기 절반 정도, 예: 50.0 ~ 150.0)
uniform float wave_frequency : hint_range(10.0, 300.0) = 80.0;

// ==========================================
// [그룹 2] Squiggle (지글거리는 흔들림 설정)
// ==========================================
group_uniforms Squiggle;
/// Noise texture scale
uniform vec2 scale = vec2(1.0, 1.0);
uniform float strength = 1.0;
/// Number of squiggle frames per second
uniform float fps = 6.0;
uniform sampler2D noise : filter_linear, repeat_enable;
group_uniforms;

varying vec4 modulate;
varying vec2 noise_uv;

// 수학 상수 정의
#define offset_multiplier vec2(PI, E)

void vertex() {
	modulate = COLOR;
	
	// 1. [Curve] 노드 자체 좌표(VERTEX.x) 기반 삼각함수 커브 적용 (render_mode 영향을 안 받음)
	VERTEX.y -= sin(VERTEX.x / wave_frequency) * wave_amplitude;
	
	// 2. [Squiggle] 월드 좌표 기반 Noise UV 계산 (MODEL_MATRIX 활용)
	vec2 world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	noise_uv = (world_pos - MODEL_MATRIX[3].xy) / (vec2(textureSize(noise, 0)) * scale);
}

void fragment() {
	// [Squiggle] 시간 기반 프레임 오프셋 계산 및 텍스처 왜곡
	vec2 noise_offset = vec2(floor(TIME * fps)) * offset_multiplier;
	float noise_sample = texture(noise, noise_uv + noise_offset).r * 4.0 * PI;
	vec2 direction = vec2(cos(noise_sample), sin(noise_sample));
	vec2 squiggle_uv = UV + direction * strength * 0.005;
	
	// 최종 색상 출력
	COLOR = texture(TEXTURE, squiggle_uv) * modulate;
}