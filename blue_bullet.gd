extends BaseBullet

func _init() -> void:
	speed = 2.0
	damage = 10
	
func _move(delta: float) -> void:
	if !is_reflected:
		var player_dir : Vector2 = (Global.player.global_position - global_position).normalized()
		global_rotation = lerp_angle(global_rotation, player_dir.angle(), 1 - exp(-5.0 * delta))
	super._move(delta)
