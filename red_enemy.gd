extends BaseEnemy

func _init() -> void:
	speed = 0.7
	stop_distance = 380.0
	charge_time = 1.1
	reposition_time = 1.0
	bullet_scene = preload("res://red_bullet.tscn")
	bronze_probability = 0.85
	silver_probability = 0.13
