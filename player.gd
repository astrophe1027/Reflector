extends Area2D
signal hit
signal died
signal health_changed(current_health:int, max_health:int)

var player_speed = 1.0

var death_particle: PackedScene = preload("res://player_death_particle.tscn")

var max_health : int = 100:
	set(value):
		max_health = value
		health_changed.emit(current_health, max_health)
var current_health : int:
	set(value):
		current_health = value
		health_changed.emit(current_health, max_health)

func _init() -> void:
	Global.player = self
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.world.player = self
	if Global.world.hard_mode:
		max_health = 70
	current_health = max_health
	
	if Global.is_saved:
		current_health = Global.save.health
		max_health = Global.save.max_health
		hit.emit()

func _process(delta: float) -> void:
	pass

	
func _physics_process(delta: float) -> void:
	if current_health>0:
		var velocity : Vector2 = Vector2.ZERO
		if Input.get_action_strength("move_right")>0.4:
			velocity.x += 1
		if Input.get_action_strength("move_left")>0.4:
			velocity.x -= 1
		if Input.get_action_strength("move_down")>0.4:
			velocity.y += 1
		if Input.get_action_strength("move_up")>0.4:
			velocity.y -= 1
			
		if velocity.length() != 0:
			velocity = velocity.normalized()
			velocity *= player_speed * Global.upgrade_manager.modifiers.speed *(1.0 + 0.2*min(1, (Global.world.player_level-1.0)/8.0))
			if find_child("Shield").visible && Global.upgrade_manager.traits.shield_fast:
				velocity*=1.3
			position += velocity
			global_position.x = clamp(global_position.x, 0, 2500)
			global_position.y = clamp(global_position.y, 0, 2500)
			if Input.is_action_just_pressed("dash") && Global.upgrade_manager.traits.dash && find_child("Shield").current_gauge > 1:
				
				# Tween 생성 및 대시 속도 애니메이션
				var tween = create_tween()
				find_child("Shield").current_gauge -= 1
				$CollisionShape2D.disabled = true
				# [속도 변화] 600의 속도로 시작해서 0.2초 동안 0으로 감속 (TRANS_EXPO + EASE_OUT으로 폭발적인 속도감)
				tween.tween_property(self, "global_position", global_position+velocity * 100.0, 0.3)\
					.set_trans(Tween.TRANS_CUBIC)\
					.set_ease(Tween.EASE_OUT)
				#get_viewport().get_camera_2d().apply_shake(7.0, 0.3)
				$GPUParticles2D.global_position = global_position+velocity * 60.0
				$GPUParticles2D.emitting = true
				#dash = false
				tween.finished.connect(func():
					$GPUParticles2D.emitting = false
					$CollisionShape2D.disabled = false
					)
				#await get_tree().create_timer(3, false, true).timeout
				#dash = true
				# 대시가 끝나면 is_dashing 해제



func _on_area_entered(area: Node2D) -> void:
	if area is BaseBullet:
		var bullet : BaseBullet = area
		if !bullet.is_reflected:
			#_hit(bullet.damage)
			bullet.queue_free()
	elif area is Coin:
		var coin : Coin = area
		if coin.exp_val > 20:
			$Coin2.play()
		else:
			$Coin.play()
	elif area.name == "Magnet":
		$Coin.play()
	elif area.name == "HealPack":
		$Coin2.play()

func _hit(damage:int) -> void:
	hit.emit()
	get_viewport().get_camera_2d().apply_shake(10.0, 0.2)
	current_health -= damage
	if current_health <= 0:
		var particle : GPUParticles2D = death_particle.instantiate()
		Global.world.add_child(particle)
		particle.global_position = global_position
		hide()
		$CollisionShape2D.set_deferred("disabled", true)
		$Area2D/CollisionShape2D.set_deferred("disabled", true)
		$Hit.volume_db = 10
		get_viewport().get_camera_2d().apply_shake(15.0, 1)
		died.emit()
	$Hit.play()
	var tween = get_tree().create_tween()
	for i in range(4):
		tween.tween_property($Polygon2D, "color:a", 0, 0.15)
		tween.tween_property($Polygon2D, "color:a", 1, 0.15)
	$CollisionShape2D.set_deferred("disabled", true)
	await get_tree().create_timer(1.2).timeout
	if current_health>0:
		$CollisionShape2D.set_deferred("disabled", false)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is BaseBullet:
		var bullet : BaseBullet = area
		if !bullet.is_reflected:
			if Global.upgrade_manager.traits.dodging_exp:
				Global.world.experience += 10
			Global.world.player.find_child("Shield").current_gauge += 0.4
			$Bullet.play()
			get_viewport().get_camera_2d().apply_shake(5.0, 0.1)
			var tween = create_tween()
			
			$Area2D/Polygon2D.color.a = 0.6 
			
			tween.tween_property($Area2D/Polygon2D, "color:a", 0.0, 0.5)\
			.set_trans(Tween.TRANS_QUAD)\
			.set_ease(Tween.EASE_OUT)
