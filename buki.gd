extends BaseEnemy

var red_bullet: PackedScene = preload("res://red_bullet.tscn")
var blue_bullet: PackedScene = preload("res://blue_bullet.tscn")
var green_bullet: PackedScene = preload("res://green_bullet.tscn")
var orange_bullet: PackedScene = preload("res://orange_bullet.tscn")
var yellow_bullet: PackedScene = preload("res://yellow_bullet.tscn")
var pink_bullet: PackedScene = preload("res://pink_bullet.tscn")

func _init() -> void:
	speed = 2
	stop_distance = 400.0
	charge_time = 1.0
	reposition_time = 1.0
	bullet_scene = preload("res://orange_bullet.tscn")
	bronze_probability = 0.1
	silver_probability = 0.1
	hp = 100
	
func _drop_coin() -> void:
	for i in range(20):
		super._drop_coin()
		
func fire(bullet:PackedScene, angle:float, speed:float = 1) -> void:
	if bullet == red_bullet:
		$Fire2.play()
	else:
		$Fire.play()
	var b : Area2D = bullet.instantiate()
	b.global_position = global_position
	b.global_rotation = angle
	b.speed *= speed
	Global.world.add_child(b)
	if bullet == yellow_bullet:
		b.is_muted = true

func fire_bullet() -> void:
	if hp < 50:
		var rand = randf()
		if rand<0.2:
			fire(orange_bullet, target_dir.angle())
			fire(orange_bullet, target_dir.angle()+0.15)
			fire(orange_bullet, target_dir.angle()-0.15)
		elif rand<0.4:
			fire(blue_bullet, 0, 2)
			fire(blue_bullet, PI/2.0, 2)
			fire(blue_bullet, PI, 2)
			fire(blue_bullet, PI/2.0*3.0, 2)
		elif rand<0.6:
			for i in range(8):
				fire(yellow_bullet, target_dir.angle()+i*PI/4)
			await get_tree().create_timer(0.7, false, true).timeout
			for i in range(8):
				fire(yellow_bullet, target_dir.angle()+i*PI/4+1)
			await get_tree().create_timer(0.7, false, true).timeout
			for i in range(8):
				fire(yellow_bullet, target_dir.angle()+i*PI/4+2)
			await get_tree().create_timer(0.7, false, true).timeout
			for i in range(8):
				fire(yellow_bullet, target_dir.angle()+i*PI/4)
			await get_tree().create_timer(1.0, false, true).timeout
		elif rand<0.8:
			for j in range(4):
				for i in range(32):
					fire(red_bullet, PI/16.0*i)
					await get_tree().create_timer(0.03, false, true).timeout
		else:
			for j in range(4):
				for i in range(3):
					fire(orange_bullet, (Global.player.global_position - global_position).angle(), 1.2)
					await get_tree().create_timer(0.1, false, true).timeout
				await get_tree().create_timer(0.5, false, true).timeout
	else:
		var rand = randf()
		if hp<70:
			rand = 0.3
		if rand<0.2:
			fire(red_bullet, target_dir.angle())
			fire(red_bullet, target_dir.angle()+0.2)
			fire(red_bullet, target_dir.angle()-0.2)
		elif rand<0.4:
			for j in range(4):
				for i in range(32):
					fire(pink_bullet, PI/16.0*i)
					await get_tree().create_timer(0.015, false, true).timeout
				for i in range(32):
					fire(pink_bullet, PI/16.0*i+PI/32)
					await get_tree().create_timer(0.015, false, true).timeout
			await get_tree().create_timer(2, false, true).timeout
		elif rand<0.6:
			for j in range(4):
				for i in range(3):
					fire(red_bullet, (Global.player.global_position - global_position).angle(), 1.2)
					await get_tree().create_timer(0.1, false, true).timeout
				await get_tree().create_timer(0.5, false, true).timeout
		elif rand<0.8:
			for i in range(16):
					fire(green_bullet, PI/8.0*i, 2.0/3.0)
			await get_tree().create_timer(1, false, true).timeout
			for i in range(16):
					fire(green_bullet, PI/8.0*i+1, 2.0/3.0)
		else:
			for j in range(3):
				for i in range(16):
					fire(pink_bullet, target_dir.angle()-1.6+i*0.2)
				await get_tree().create_timer(0.6, false, true).timeout
				for i in range(16):
					fire(pink_bullet, target_dir.angle()+1.6-i*0.2-0.1)
				await get_tree().create_timer(0.6, false, true).timeout

func _on_targeted() -> void:
	is_targeted = false
