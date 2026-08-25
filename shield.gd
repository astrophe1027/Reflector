extends Area2D

var current_gauge: float = 5.0
var max_gauge = 5.0
var regen_rate = 1.0
var is_overheated: bool = false

var upgrade_manager = Global.upgrade_manager

var revolving_bullet_scene: PackedScene = preload("res://revolving_bullet.tscn")
var sub_bullet_scene: PackedScene = preload("res://red_bullet.tscn")

var ring_texture: Texture2D = preload("res://assets/ring.png")

var _last_closest_bullet: Node2D = null

signal overheated

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.is_saved:
		scale.y = Global.save.shield_size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	update_closest_bullet_outline()
	var level_progress = clamp((Global.world.player_level-1.0) / 8.0, 0.0, 1.0)
	max_gauge = lerp(4.0, 5.0, level_progress) * upgrade_manager.modifiers.shield_max
	regen_rate = lerp(0.3, 0.6, level_progress) * upgrade_manager.modifiers.shield_regen
	var gauge_progress = clamp(current_gauge/max_gauge, 0.0, 1.0)
	if gauge_progress > 0.5:
		$Polygon2D.modulate = Color.ORANGE.lerp(Color.CYAN, (gauge_progress-0.5)*2)
		$Sprite2D.modulate = Color.ORANGE.lerp(Color.CYAN, (gauge_progress-0.5)*2)
	else:
		$Polygon2D.modulate = Color.RED.lerp(Color.ORANGE, gauge_progress*2)
		$Sprite2D.modulate = Color.RED.lerp(Color.ORANGE, gauge_progress*2)
	#var hue = lerp(0.0, 0.5, gauge_progress) # 청록(0.5)에서 빨강(0.0)으로 색상 축 이동
	#$Polygon2D.modulate = Color.from_hsv(hue, 1.0, 1.0) # 채도 100%, 명도 100% 유지
	
	if not is_overheated and current_gauge > 0:
		var velocity = Vector2.ZERO
		if Input.get_action_strength("shield_up")>0.4:
			velocity += Vector2(0, -1)
		elif Input.get_action_strength("shield_down")>0.4:
			velocity += Vector2(0, 1)
		if Input.get_action_strength("shield_left")>0.4:
			velocity += Vector2(-1, 0)
		elif Input.get_action_strength("shield_right")>0.4:
			velocity += Vector2(1, 0)
		if Input.is_action_pressed("auto_shield") && upgrade_manager.traits.auto_shield:
			var bullets = get_tree().get_nodes_in_group("Bullet")
			var closest_bullet: Node2D = null
			var min_distance: float = INF 
			
			for bullet: BaseBullet in bullets:
				if is_instance_valid(bullet) and not bullet.is_reflected:
					var dist_sq = get_parent().global_position.distance_squared_to(bullet.global_position)
					if dist_sq > 4225.0 and dist_sq < min_distance: # 65.0^2 = 4225.0
						min_distance = dist_sq
						closest_bullet = bullet
			if closest_bullet != null:
				if !visible:
					show()
					$CollisionShape2D.set_deferred("disabled", false)
				current_gauge -= 1.0/60.0
				var direction = (closest_bullet.global_position - get_parent().global_position).normalized()
				velocity = Vector2.from_angle(snapped(direction.angle(), PI/4))
		if velocity.length() != 0:
			current_gauge -= 1.0/60.0
			if current_gauge <= 0.0:
					current_gauge = 0.0
					is_overheated = true
					overheated.emit()
					get_viewport().get_camera_2d().apply_shake(8.0, 0.2)
					if visible:
						hide()
						$CollisionShape2D.set_deferred("disabled", true)
			else:
				if !visible:
					show()
					$CollisionShape2D.set_deferred("disabled", false)
				velocity = velocity.normalized()
				global_rotation = velocity.angle()
				global_position = get_parent().global_position + velocity*55
		else:
			current_gauge += regen_rate * 1.0/60.0
			if current_gauge >= max_gauge:
				current_gauge = max_gauge
			if is_overheated and current_gauge >= (max_gauge * 0.20):
				is_overheated = false
			if visible:
				hide()
				$CollisionShape2D.set_deferred("disabled", true)
	else:
		current_gauge += regen_rate * 1.0/60.0
		if current_gauge >= max_gauge:
			current_gauge = max_gauge
		if is_overheated and current_gauge >= (max_gauge * 0.20):
			is_overheated = false
		if visible:
			hide()
			$CollisionShape2D.set_deferred("disabled", true)
			
func update_closest_bullet_outline() -> void:
	var bullets = get_tree().get_nodes_in_group("Bullet")
	
	# 트리에 총알이 없으면 이전 외곽선 끄고 종료
	if bullets.is_empty():
		if is_instance_valid(_last_closest_bullet) and _last_closest_bullet.has_method("set_outline_enabled"):
			_last_closest_bullet.set_outline_enabled(false)
			_last_closest_bullet = null
		return

	var closest_bullet: Node2D = null
	var min_distance_sq: float = INF # 제곱 거리 비교 (performance 최적화)

	# 가장 가까운 총알 탐색
	for bullet in bullets:
		if not is_instance_valid(bullet):
			continue
			
		var distance_sq = global_position.distance_squared_to(bullet.global_position)
		if distance_sq < min_distance_sq:
			min_distance_sq = distance_sq
			closest_bullet = bullet

	# 가장 가까운 총알이 바뀐 경우 처리
	if _last_closest_bullet != closest_bullet:
		# 이전 총알 외곽선 끄기
		if is_instance_valid(_last_closest_bullet) and _last_closest_bullet.has_method("set_outline_enabled"):
			_last_closest_bullet.set_outline_enabled(false)
		
		# 새 총알 외곽선 켜기
		if is_instance_valid(closest_bullet) and closest_bullet.has_method("set_outline_enabled"):
			closest_bullet.set_outline_enabled(true)
			
		_last_closest_bullet = closest_bullet
		
func spawn_shockwave_ring(impact_position: Vector2) -> void:
	var ring = Sprite2D.new()
	ring.texture = ring_texture
	#ring.global_rotation = global_rotation
	ring.scale = Vector2(0.2, 0.2) # 아주 작은 크기에서 시작
	ring.modulate = Color(0.915, 0.915, 1.224, 1.0) # 살짝 푸른빛 + 쨍한 밝기(HDR)
	ring.material = CanvasItemMaterial.new()
	ring.material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	ring.z_index = z_index + 1
	ring.global_position = impact_position
	Global.world.add_child(ring)

	#ring.top_level = true
	# Tween으로 확산 연출
	var tween = create_tween().set_parallel(true)
	# 1. 크기 3배로 빠르게 확장 (EASE_OUT으로 팍 켜지는 느낌)
	tween.tween_property(ring, "scale", Vector2(1.5, 1.5), 0.12)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# 2. 동시에 투명도 0으로 알파 감소
	tween.tween_property(ring, "modulate:a", 0.0, 0.12).set_ease(Tween.EASE_IN)
	
	# 애니메이션 끝나면 바로 메모리 해제
	tween.chain().tween_callback(ring.queue_free)

func spawn_bullet_sparks(bullet: Node2D) -> void:
	var particle = CPUParticles2D.new()
	particle.top_level = true
	# 1. basic 파티클 세팅 (1회성 노출)
	particle.emitting = false
	particle.one_shot = true
	particle.explosiveness = 1.0  # 순간적으로 팍 튀어나감
	particle.amount = 6          # 파편 개수
	particle.lifetime = 0.3      # 파편 유지 시간 (짧고 굵게)
	
	# 2. 탄환의 색상 그대로 가져오기
	particle.color = bullet.find_child("Polygon2D").color
	
	# 3. 속도 및 방향 설정 (날아온 반대 방향으로 튕겨나가도록)
	particle.direction = Vector2.from_angle(global_rotation) # 탄환의 진행 방향 반대
	particle.spread = 70.0                  # 45도 범위로 부채꼴 모양 분산
	particle.initial_velocity_min = 200.0   # 최소 튀는 속도
	particle.initial_velocity_max = 400.0   # 최대 튀는 속도
	
	# 4. 물리/감속 (파편이 튀었다가 멈추는 느낌)
	particle.damping_min = 300.0
	particle.damping_max = 500.0
	particle.gravity = Vector2.ZERO
	
	# 5. 크기 변형 (점점 작아지면서 소멸)
	particle.scale_amount_min = 10.0
	particle.scale_amount_max = 20.0
	var scale_curve = Curve.new()
	scale_curve.add_point(Vector2(0, 1)) # 시작 크기 100%
	scale_curve.add_point(Vector2(1, 0)) # 끝 크기 0%
	particle.scale_amount_curve = scale_curve

	# 6. 위치 지정 및 씬에 추가
	particle.global_position = bullet.global_position
	get_parent().add_child(particle)
	# 파티클 재생
	particle.emitting = true
	get_tree().create_timer(particle.lifetime + 0.05).timeout.connect(particle.queue_free)
	
func play_parry_kick(camera: Camera2D, bullet_dir: Vector2) -> void:
	# 탄환 진행 방향의 반대(튕겨 나가는 방향)로 8px 정도 화면 이동
	var kick_offset = bullet_dir.normalized() * 8.0
	
	var tween = create_tween()
	# 빠르게 밀렸다가 복귀
	tween.tween_property(camera, "offset", kick_offset, 0.03)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "offset", Vector2.ZERO, 0.1)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
func reflect(bullet:BaseBullet) -> void:
	var enemies = get_tree().get_nodes_in_group("Enemy")
	if enemies.size() == 0:
		pass
	var closest_enemy: BaseEnemy = null
	var min_distance: float = INF
	
	var player_pos = get_parent().global_position
	
	for enemy: BaseEnemy in enemies:
		if is_instance_valid(enemy) and not enemy.is_targeted:
			if global_transform.x.dot((enemy.global_position - global_position).normalized()) > 0:
				var dist_sq = player_pos.distance_squared_to(enemy.global_position)
				if dist_sq < min_distance:
					min_distance = dist_sq
					closest_enemy = enemy
	if !is_instance_valid(closest_enemy):
		bullet.global_rotation = Vector2.RIGHT.rotated(bullet.global_rotation).bounce(global_transform.x).angle()
	else:
		bullet.global_rotation = (closest_enemy.global_position - bullet.global_position).angle()
		closest_enemy.is_targeted = true
	bullet.is_reflected = true
	if bullet.speed <= 3:
		bullet.speed *= 3
	else:
		bullet.speed *= 2
	bullet.speed *= upgrade_manager.modifiers.reflect_speed
func _on_area_entered(area: Area2D) -> void:
	if area is BaseBullet:
		var bullet : BaseBullet = area
		if (global_transform.x.dot(global_position - bullet.global_position) < 0 || Vector2.from_angle(bullet.global_rotation).dot(Vector2.from_angle(global_rotation)) < 0.0) && !bullet.is_reflected:
			#get_viewport().get_camera_2d().apply_shake(5.0, 0.1)
			Global.world.score += 20
			$Reflect.play()
			if Global.graphic_effect:
				spawn_shockwave_ring(bullet.global_position)
				spawn_bullet_sparks(bullet)
			play_parry_kick(get_viewport().get_camera_2d(), Vector2.from_angle(bullet.global_rotation))
			current_gauge -= 0.1
			
			reflect(bullet)
			
			if upgrade_manager.traits.revolving_bullet && randf()<0.3:
				var b = revolving_bullet_scene.instantiate()
				Global.world.add_child(b)
				b.global_position = bullet.global_position
				b.global_rotation = bullet.global_rotation
			if upgrade_manager.traits.split_bullet && randf()<0.3:
				for i in range(2):
					var b = sub_bullet_scene.instantiate()
					Global.world.add_child(b)
					b.global_position = bullet.global_position
					b.speed *= 1.5
					b.is_reflected = true
					b.speed *= upgrade_manager.modifiers.reflect_speed
					if i == 0:
						b.global_rotation = bullet.global_rotation+0.15
					else:
						b.global_rotation = bullet.global_rotation-0.15
	elif area is BaseEnemy && upgrade_manager.traits.shield_bash:
		var enemy:BaseEnemy = area
		if(!enemy.is_in_group("Boss")):
			for i in range(enemy.hp):
				enemy._hit()
				Global.world.score += 100
				
