extends BaseBullet

var is_stopped : bool = false
var sub_bullet : PackedScene = preload("res://yellow_sub_bullet.tscn")
var is_muted : bool = false

func _init() -> void:
	speed = 2.5
	damage = 20
func _ready() -> void:
	$ExplodeTimer.timeout.connect(_on_explode_timer_timeout)
	super._ready()
func _physics_process(delta: float) -> void:
	if !is_stopped:
		super._move(delta)
	else:
		queue_redraw()
		if is_reflected:
			super._move(delta)
	
func _draw() -> void:
	if !is_reflected && is_stopped:
		var dir : Vector2 = Vector2.UP.rotated(-global_rotation)
		for i in range(8):
			var percent = 1.0 - ($ExplodeTimer.time_left / 1)
			percent = clamp(percent, 0.0, 1.0)
			
			var dynamic_alpha = 0.1 + percent * 0.75
			var line_length = 1300*percent
			var dynamic_width = 2 * (1-percent) + 1
			var end_point = dir * line_length
			var line_color = Color(1.0, 0.0, 0.0, dynamic_alpha)
			draw_line(Vector2.ZERO, end_point, line_color, dynamic_width)
			dir = dir.rotated(PI/4)
func _on_explode_timer_timeout() -> void:
	if !is_stopped:
		is_stopped = true 
		$ExplodeTimer.start(1)
	else:
		explode()

func explode() -> void:
	get_viewport().get_camera_2d().apply_shake(10.0, 0.5)
	var dir : Vector2 = Vector2.UP
	for i in range(8):
		var b : BaseBullet = sub_bullet.instantiate()
		b.global_position = global_position
		b.global_rotation = dir.angle()
		Global.world.add_child(b)
		b.speed = 3
		if is_reflected:
			b.is_reflected = true
		dir = dir.rotated(PI/4)
	if $Explode != null:
		if is_muted:
			$Explode.volume_db = -8
		$Explode.play()
		$Explode.finished.connect($Explode.queue_free)
		$Explode.reparent(get_parent())
	queue_free()
