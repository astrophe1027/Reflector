extends BaseEnemy

var red_bullet: PackedScene = preload("res://red_bullet.tscn")
var blue_bullet: PackedScene = preload("res://blue_bullet.tscn")
var green_bullet: PackedScene = preload("res://green_bullet.tscn")
var orange_bullet: PackedScene = preload("res://orange_bullet.tscn")
var yellow_bullet: PackedScene = preload("res://yellow_bullet.tscn")
var pink_bullet: PackedScene = preload("res://pink_bullet.tscn")

var heal_pack: PackedScene = preload("res://heal_pack.tscn")
var healed:bool = false

var phase:int = 0

var max_hp : int = 200

var difficulty:float = 1

func _init() -> void:
	speed = 2
	stop_distance = 400.0
	charge_time = 1.0
	reposition_time = 1.0
	bullet_scene = preload("res://orange_bullet.tscn")
	bronze_probability = 0.1
	silver_probability = 0.1
	max_hp = 200
	hp = 200
	if Global.world.easy_mode:
		hp = 100
		max_hp = 100
		difficulty = 1.5
	elif Global.world.hard_mode:
		hp = 200
		max_hp = 200
		difficulty = 1.0
	else:
		hp = 150
		max_hp = 150
		difficulty = 1.2
	
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
	if is_inside_tree():
		Global.world.add_child(b)
	if bullet == yellow_bullet:
		b.is_muted = true

func rand_tp() -> void:
	var v = Vector2.from_angle(2*PI*randf()) * 300
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", Global.player.global_position+v, 0.3).set_trans(Tween.TRANS_CUBIC)
	await get_tree().create_timer(0.3, false, true).timeout

func fire_bullet() -> void:
	if phase == 0:
		var m = magnet.instantiate()
		m.velocity = (Global.player.global_position-global_position).normalized()*20
		m.global_position = global_position
		Global.world.add_child(m)
		var h = heal_pack.instantiate()
		h.velocity = (Global.player.global_position-global_position).normalized()*23
		h.global_position = global_position
		Global.world.add_child(h)
		await get_tree().create_timer(3, false, true).timeout
		$AnimatedSprite2D.play("start")
		await get_tree().create_timer(4, false, true).timeout
		Global.world.find_child("BGM").boss()
		Global.world.save()
		await get_tree().create_timer(1, false, true).timeout
		phase = 1
	elif phase == 1:
		if hp < max_hp/2:
			var rand = randf()
			if rand<0.2:
				for j in range(int(15/difficulty)):
					if randf()<0.5:
						fire(pink_bullet, target_dir.angle(), 1.5)
						fire(pink_bullet, target_dir.angle()+0.3, 1.5)
						fire(pink_bullet, target_dir.angle()-0.3, 1.5)
					else:
						fire(pink_bullet, target_dir.angle()+0.2, 1.5)
						fire(pink_bullet, target_dir.angle()-0.2, 1.5)
					await rand_tp()
					await get_tree().create_timer(0.1*difficulty, false, true).timeout
					target_dir = Global.player.global_position - global_position
					await get_tree().create_timer(0.15*difficulty, false, true).timeout
			elif rand<0.4:
				for j in range(int(10/difficulty)):
					fire(yellow_bullet, target_dir.angle(), 1.5)
					await rand_tp()
					target_dir = Global.player.global_position - global_position
					await get_tree().create_timer(0.1*difficulty, false, true).timeout
			elif rand<0.6:
				for j in range(int(12/difficulty)):
					for i in range(4):
						fire(red_bullet, target_dir.angle(), 1.4)
						await get_tree().create_timer(0.07, false, true).timeout
					await rand_tp()
					target_dir = Global.player.global_position - global_position
					await get_tree().create_timer(0.15*difficulty, false, true).timeout
			elif rand<0.8:
				for j in range(int(10/difficulty)):
					fire(red_bullet, target_dir.angle())
					fire(red_bullet, target_dir.angle()+0.3)
					fire(red_bullet, target_dir.angle()-0.3)
					await get_tree().create_timer(0.1*difficulty, false, true).timeout
					await rand_tp()
					target_dir = Global.player.global_position - global_position
					await get_tree().create_timer(0.15*difficulty, false, true).timeout
					for i in range(3):
						fire(red_bullet, target_dir.angle(), 1.2)
						await get_tree().create_timer(0.07*difficulty, false, true).timeout
					await rand_tp()
					target_dir = Global.player.global_position - global_position
					await get_tree().create_timer(0.3*difficulty, false, true).timeout
			else:
				for j in range(int(14/difficulty)):
					fire(pink_bullet, target_dir.angle(), 2)
					await rand_tp()
					target_dir = Global.player.global_position - global_position
					await get_tree().create_timer(0.1*difficulty, false, true).timeout
		else:
			var rand = randf()
			if rand<0.2:
				for j in range(int(8/difficulty)):
					fire(red_bullet, target_dir.angle(), 0.8)
					fire(red_bullet, target_dir.angle()+0.3, 0.8)
					fire(red_bullet, target_dir.angle()-0.3, 0.8)
					await get_tree().create_timer(0.1*difficulty, false, true).timeout
					await rand_tp()
					target_dir = Global.player.global_position - global_position
					await get_tree().create_timer(0.15*difficulty, false, true).timeout
			elif rand<0.4:
				for j in range(2):
					for i in range(32):
						fire(pink_bullet, PI/16.0*i)
						await get_tree().create_timer(0.015, false, true).timeout
					for i in range(32):
						fire(pink_bullet, PI/16.0*i+PI/32)
						await get_tree().create_timer(0.015, false, true).timeout
				await get_tree().create_timer(2*difficulty, false, true).timeout
			elif rand<0.6:
				for j in range(int(10/difficulty)):
					for i in range(3):
						fire(red_bullet, target_dir.angle(), 1.2)
						await get_tree().create_timer(0.07, false, true).timeout
					await rand_tp()
					target_dir = Global.player.global_position - global_position
					await get_tree().create_timer(0.5*difficulty, false, true).timeout
			elif rand<0.8:
				for i in range(16):
						fire(green_bullet, PI/8.0*i, 2.0/3.0)
				await get_tree().create_timer(1, false, true).timeout
				for i in range(16):
						fire(green_bullet, PI/8.0*i+1, 2.0/3.0)
			else:
				for j in range(int(10/difficulty)):
					fire(pink_bullet, target_dir.angle(), 2)
					await get_tree().create_timer(0.1*difficulty, false, true).timeout
					await rand_tp()
					target_dir = Global.player.global_position - global_position
					await get_tree().create_timer(0.1*difficulty, false, true).timeout



func _on_targeted() -> void:
	is_targeted = false

func _draw() -> void:
	pass
		
func _hit() -> void:
	hp -= 1
	var audio : AudioStreamPlayer = $Hit
	if audio != null:
		audio.play()
	if hp<=max_hp/2 && !healed:
		healed = true
		var h = heal_pack.instantiate()
		h.velocity = (Global.player.global_position-global_position).normalized()*23
		h.global_position = global_position
		Global.world.add_child(h)
		
	if hp<=0:
		var particle : GPUParticles2D = death_particle.instantiate()
		particle.process_material.color = $Polygon2D.color
		if is_inside_tree():
			Global.world.add_child(particle)
		particle.global_position = global_position
		_drop_coin()
		if randf() < 0.015:
			var magnet_instance = magnet.instantiate()
			magnet_instance.global_position = global_position
			if is_inside_tree():
				Global.world.add_child(magnet_instance)
		if audio != null:
			$Hit.reparent(get_parent())
			audio.finished.connect(audio.queue_free)
		queue_free()
