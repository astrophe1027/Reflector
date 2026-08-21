extends BaseEnemy

func _init() -> void:
	speed = 1.2
	stop_distance = 280.0
	charge_time = 1.1
	reposition_time = 1.0
	bullet_scene = preload("res://blue_bullet.tscn")
	bronze_probability = 0.3
	silver_probability = 0.6
