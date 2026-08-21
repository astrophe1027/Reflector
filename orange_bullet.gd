extends BaseBullet

var reflect = 2
var turn_speed = 1.0
func _init() -> void:
	speed = 8.0
	damage = 10
	reflect = 1
	
func _move(delta: float) -> void:
	if is_reflected && reflect > 0:
		reflect-=1
		is_reflected=false
		$Polygon2D.color = Color(1.0, 0.557, 0.0, 1.0)
		$GPUParticles2D.process_material.color = Color(1.0, 0.765, 0.0, 0.702)
		speed /= 2
		turn_speed = 0.01
	elif !is_reflected && reflect != 1:
		var player_dir : Vector2 = (Global.world.player.global_position - global_position).normalized()
		global_rotation = lerp_angle(global_rotation, player_dir.angle(), turn_speed)
		if turn_speed < 1:
			turn_speed += 0.001
	super._move(delta)
