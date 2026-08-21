extends BaseEnemy

var wave_sign : bool

func _init() -> void:
	speed = 0.8
	stop_distance = 320.0
	charge_time = 0.7
	if Global.world.easy_mode:
		charge_time = 1.5
	elif !Global.world.hard_mode:
		charge_time = 1.0
	reposition_time = 1.0
	hp = 2
	if Global.world.easy_mode:
		hp = 1
	bullet_scene = preload("res://green_bullet.tscn")
	bronze_probability = 0.2
	silver_probability = 0.5

func _physics_process(delta: float) -> void:
	var to_player = Global.player.global_position - global_position
	var distance = to_player.length()
	var direction_to_player = to_player.normalized()
	
	match current_state:
		AiState.APPROACH:
			var screen_pos = get_canvas_transform() * global_position
			var view_size = get_viewport_rect().size
			var in_x = screen_pos.x > 30 and screen_pos.x < (view_size.x - 30)
			var in_y = screen_pos.y > 30 and screen_pos.y < (view_size.y - 30)
			var is_visible_on_screen : bool = in_x && in_y
			if distance > stop_distance || !is_visible_on_screen:
				position += direction_to_player * speed
			else:
				current_state = AiState.CHARGE
				wave_sign = randi()%2==0
				target_dir = direction_to_player
				$ChargeTimer.start(charge_time)
				
		AiState.CHARGE:
			queue_redraw()
		
		AiState.REPOSITION:
			if distance < stop_distance + 10.0:
				position += -direction_to_player * speed * 1.2
			else:
				var side_dir
				if reposition_direction:
					side_dir = Vector2(-direction_to_player.y, direction_to_player.x)
				else:
					side_dir = Vector2(direction_to_player.y, -direction_to_player.x)
				position += side_dir * speed * 1.2

func fire_bullet() -> void:
	var b = bullet_scene.instantiate()
	b.global_position = global_position
	b.global_rotation = target_dir.angle()
	b.wave_sign = wave_sign
	Global.world.add_child(b)
	
func _draw() -> void:
	if current_state == AiState.CHARGE:
		var percent = 1.0 - ($ChargeTimer.time_left / charge_time)
		percent = clamp(percent, 0.0, 1.0)
		
		var dynamic_alpha = 0.1 + percent * 0.75
		var dynamic_width = 11.5 * (1-percent) + 2.5
		var line_length = 1200 * percent # 차지 시간에 따라 예측선이 앞으로 뻗어나감
		
		var line_color = Color(0.0, 1.0, 0.3, dynamic_alpha) # 초록색 탄막이므로 초록 계열로 세팅
		
		# 🎯 사인파 예측선 그리기 로직
		# 1. 현재 적 노드의 회전 오차를 상쇄한 정면 방향 벡터와 수직 방향 벡터를 구합니다.
		var forward_dir = target_dir.rotated(-global_rotation).normalized()
		var perpendicular_dir = Vector2(-forward_dir.y, forward_dir.x)
		
		# HTML 방식의 wave_sign 방향성 반영 (적이 발사할 탄의 wave_sign을 미리 알고있다면 매칭)
		var sign_multiplier = 1.0 # 필요시 탄막과 100% 일치시키려면 변수 연동 가능
		if !wave_sign:
			sign_multiplier = -1.0
		
		var points: Array[Vector2] = []
		var step_distance = 15.0 # 곡선을 쪼갤 촘촘함 (숫자가 작을수록 부드러운 곡선이 됩니다)
		
		# 2. 앞으로 나아갈 길이만큼 루프를 돌며 곡선의 점(Point)들을 계산합니다.
		var current_dist = 0.0
		while current_dist < line_length:
			# 탄막 코드의 step_count는 거리와 비례하므로 (거리 / speed)로 가상 step을 역산합니다.
			# 탄막 속도(speed = 9.0) 기준
			var virtual_step = (current_dist / 3.5) * 0.7
			# 탄막과 동일한 공식으로 사인 오프셋 계산
			var wave_offset = sin(virtual_step * 0.095) * 110.0 * sign_multiplier
			# 정방향 위치 + 수직 사인 변위
			var pt = (forward_dir * current_dist) + (perpendicular_dir * wave_offset)
			points.append(pt)
			current_dist += step_distance
		if points.size() > 1:
			for i in range(points.size() - 1):
				draw_line(points[i], points[i+1], line_color, dynamic_width)

func _drop_coin() -> void:
	for i in range(2):
		super._drop_coin()
