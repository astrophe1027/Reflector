extends BaseBullet

var wave_sign: bool = true
var step_count: float = 0.0

@onready var direction: Vector2 = Vector2.from_angle(global_rotation).normalized()
@onready var perpendicular_dir: Vector2 = direction.rotated(PI/2)

func _init() -> void:
	speed = 3.5
	damage = 10

func _move(delta: float) -> void:
	if !is_reflected:
		var prev_step = step_count
		step_count += 0.7
		
		var current_wave = sin(step_count * 0.095) * 110.0
		var prev_wave = sin(prev_step * 0.095) * 110.0
		var wave_diff = current_wave - prev_wave
		
		var sign_multiplier = 1.0 if wave_sign else -1.0
		var wave_offset = wave_diff * sign_multiplier
		global_position += perpendicular_dir * wave_offset
	super._move(delta)
		
