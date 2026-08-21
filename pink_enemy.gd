extends BaseEnemy

func _init() -> void:
	speed = 0.6
	stop_distance = 400.0
	charge_time = 1.4
	reposition_time = 1.0
	if Global.world.hard_mode:
		hp = 2
	else:
		hp = 1
	bullet_scene = preload("res://pink_bullet.tscn")
	bronze_probability = 0.3
	silver_probability = 0.6

func _draw() -> void:
	if current_state == AiState.CHARGE:
		var percent = 1.0 - ($ChargeTimer.time_left / charge_time)
		percent = clamp(percent, 0.0, 1.0)
		
		var dynamic_alpha = 0.1 + percent * 0.75
		var dynamic_width = 15 * (1-percent) + 2.5
		var line_length = 1300*percent
		
		var end_point = target_dir * line_length
		var line_color = Color($Polygon2D.color, dynamic_alpha)
		draw_line(Vector2.ZERO, end_point, line_color, dynamic_width)

func _hit() -> void:
	$AnimatedSprite2D.animation = "hitted"
	super._hit()
