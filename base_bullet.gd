class_name BaseBullet
extends Area2D

var speed: float = 9.0
var damage: int = 10

var target: BaseEnemy = null

var is_reflected: bool = false:
	set(value):
		is_reflected = value
		if value:
			_reflected()

func _reflected() -> void:
	$Polygon2D.color = Color(0.0, 1.0, 1.0, 1.0)
	$GPUParticles2D.color = Color(0.0, 1.0, 1.0, 1.0)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_visible_on_screen_notifier_2d_screen_exited)

func _physics_process(delta: float) -> void:
	_move(delta)
	
func _move(delta: float) -> void:
	var velocity = Vector2.from_angle(global_rotation)
	position += velocity * speed
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
