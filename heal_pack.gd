class_name HealPack
extends Area2D

var velocity: Vector2 = Vector2.ZERO
var friction: float = 0.925
var magnet_speed: float = 0.375
var max_magnet_speed: float = 10.5
var base_magnet_range: float = 100.0

func _ready() -> void:
	if velocity==Vector2.ZERO:
		# 1. 초기 생성 시 무작위 방향으로 튕겨 나가는 관성 부여
		var angle = randf_range(0, PI * 2)
		var speed = randf_range(0, 2.25)
		velocity = Vector2(cos(angle), sin(angle)) * speed

func _physics_process(_delta: float) -> void:
	# 마찰력 적용 및 이동
	velocity *= friction
	global_position += velocity
		
	# 자석 시스템 기능 구현
	var dist = global_position.distance_to(Global.player.global_position)
	
	# 플레이어의 자석 범위 모디파이어 변수 반영 (기본값 1.0)
	var magnet_modifier = 1.0
	var final_range = base_magnet_range * magnet_modifier
	
	if dist < final_range:
		var dir = (Global.player.global_position - global_position).normalized()
		velocity += dir * magnet_speed
		
		# 속도 상한선 제한
		if velocity.length() > max_magnet_speed:
			velocity = velocity.normalized() * max_magnet_speed

func _on_area_entered(area: Node2D) -> void:
	if area.is_in_group("Player"):
		Global.player.current_health = Global.player.max_health
		
		queue_free() # 코인 소멸
