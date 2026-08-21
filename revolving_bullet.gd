extends BaseBullet

var is_revolving: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_reflected = true
	speed = 12.0
	damage = 10
	while target==null:
		await get_tree().create_timer(randf()*3+1, false, true).timeout
		_find_target()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _find_target() -> void:
	var enemies = get_tree().get_nodes_in_group("Enemy")
	var dir_vector = Vector2.RIGHT.rotated(global_rotation)
	var min_dist: float = INF
	#for enemy : BaseEnemy in enemies:
		#var v = enemy.global_position - global_position
		#var enemy_facing: Vector2 = Vector2.RIGHT.rotated(enemy.global_rotation)
		#var cross_product: float = sign(Vector2.RIGHT.rotated(global_rotation).cross(v))
		#var player_dir : Vector2 = (Global.world.player.global_position - global_position)
		#var player_cross: float = sign(Vector2.RIGHT.rotated(global_rotation).cross(player_dir))
		#if player_cross != cross_product && enemy.is_targeted:
			#continue
		#if v.dot(dir_vector) > 0:
			#var perp_dist = abs(v.cross(dir_vector))
			#if perp_dist < min_dist:
				#min_dist = perp_dist
				#target = enemy
	for enemy : BaseEnemy in enemies:
		var screen_pos = get_canvas_transform() * enemy.global_position
		var view_size = get_viewport_rect().size
		var in_x = screen_pos.x > 30 and screen_pos.x < (view_size.x - 30)
		var in_y = screen_pos.y > 30 and screen_pos.y < (view_size.y - 30)
		var is_visible_on_screen : bool = in_x && in_y
		if !is_visible_on_screen:
			continue
		if enemy.global_position.distance_to(Global.world.player.global_position) < min_dist && !enemy.is_targeted:
			min_dist = enemy.global_position.distance_to(Global.world.player.global_position)
			target = enemy
	if target != null:
		target.is_targeted = true
		$Polygon2D.color = Color(1.0, 1.0, 1.0, 1.0)
		$GPUParticles2D.process_material.color = Color(1.0, 1.0, 1.0, 1.0)
		speed *= 1.5

func _physics_process(delta: float) -> void:
	_move(delta)
			
func _move(delta: float) -> void:
	if is_revolving:
		var player_dir : Vector2 = (Global.world.player.global_position - global_position).normalized()
		global_rotation = lerp_angle(global_rotation, player_dir.angle(), 0.08)
		if target != null:
			var dir_vector = Vector2.RIGHT.rotated(global_rotation)
			var v : Vector2 = target.global_position - global_position
			if v.dot(dir_vector) > 0:
				var perp_dist = abs(v.cross(dir_vector))
				if perp_dist < 50:
					global_rotation = v.angle()
					is_revolving = false
					$Fire.play()
					speed *= 1.5
	super._move(delta)
