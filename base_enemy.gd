class_name BaseEnemy
extends Area2D

var speed = 0.6
var stop_distance = 380.0
var charge_time = 1.1
var reposition_time = 1.0
var hp = 1

var is_targeted = false:
	set(value):
		is_targeted = value
		if value:
			_on_targeted()

enum AiState { APPROACH, CHARGE, REPOSITION }
var current_state : AiState = AiState.APPROACH
var reposition_direction : bool

var target_dir : Vector2 = Vector2.ZERO

var death_particle: PackedScene = preload("res://death_particle.tscn")
var bullet_scene: PackedScene = preload("res://base_bullet.tscn")

var magnet: PackedScene = preload("res://magnet.tscn")
var coin: PackedScene = preload("res://coin.tscn")
var bronze_probability : float = 0.85
var silver_probability : float = 0.13

func _on_targeted() -> void:
	await get_tree().create_timer(1).timeout
	is_targeted = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ChargeTimer.timeout.connect(_on_charge_timer_timeout)
	$RepositionTimer.timeout.connect(_on_reposition_timer_timeout)
	area_entered.connect(_on_area_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if is_instance_valid(Global.player):
		var is_player_on_left: bool = Global.player.global_position.x < global_position.x
		$AnimatedSprite2D.flip_h = is_player_on_left
		
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
			
func _draw() -> void:
	if current_state == AiState.CHARGE:
		var percent = 1.0 - ($ChargeTimer.time_left / charge_time)
		percent = clamp(percent, 0.0, 1.0)
		
		var dynamic_alpha = 0.1 + percent * 0.75
		var dynamic_width = 11.5 * (1-percent) + 2.5
		var line_length = 1300*percent
		
		var end_point = target_dir * line_length
		var line_color = Color($Polygon2D.color, dynamic_alpha)
		draw_line(Vector2.ZERO, end_point, line_color, dynamic_width)

func _on_charge_timer_timeout() -> void:
	await fire_bullet()
	current_state = AiState.REPOSITION
	reposition_direction = randi() % 2 == 0
	$RepositionTimer.start(reposition_time*randf_range(0.5, 1.5))
	queue_redraw()
	
func _on_reposition_timer_timeout() -> void:
	current_state = AiState.APPROACH
	
func fire_bullet() -> void:
	$Fire.play()
	var b = bullet_scene.instantiate()
	b.global_position = global_position
	b.global_rotation = target_dir.angle()
	if is_inside_tree():
		Global.world.add_child(b)


func _on_area_entered(area: Area2D) -> void:
	if area is BaseBullet:
		var bullet : BaseBullet = area
		if bullet.is_reflected:
			if bullet.has_method("explode"):
				bullet.explode()
			else:
				area.queue_free()
			_hit()
			

func _hit() -> void:
	hp -= 1
	var audio : AudioStreamPlayer = $Hit
	if audio != null:
		audio.play()
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
		
func _drop_coin() -> void:
	var rand = randf()
	var selected_type = "bronze"
	if rand < bronze_probability: selected_type = "bronze"
	elif rand < bronze_probability + silver_probability: selected_type = "silver"
	else: selected_type = "gold"
	
	var coin_instance = coin.instantiate()
	coin_instance.coin_type = selected_type
	coin_instance.global_position = global_position
	if is_inside_tree():
		Global.world.add_child(coin_instance)
	
