class_name Coin
extends Area2D

var coin_type: String = "bronze"
var value: float = 100.0
var exp_val: int = 10
var color: Color = Color("#cd7f32")

var velocity: Vector2 = Vector2.ZERO
var friction: float = 0.925
var magnet_speed: float = 0.5
var max_magnet_speed: float = 10.5
var base_magnet_range: float = 100.0

var player: Node2D = null

func _ready() -> void:
	# 1. 초기 생성 시 무작위 방향으로 튕겨 나가는 관성 부여
	var angle = randf_range(0, PI * 2)
	var speed = randf_range(0, 3.0)
	velocity = Vector2(cos(angle), sin(angle)) * speed
	
	# 2. 타입별 능력치 초기화
	_init_coin_stats()
	
	player = Global.player

func _init_coin_stats() -> void:
	match coin_type:
		"bronze":
			color = Color("#cd7f32")
			value = 100.0
			exp_val = 10
		"silver":
			color = Color("#cccccc")
			value = 400.0
			exp_val = 30
		"gold":
			color = Color("#ffd700")
			value = 1000
			exp_val = 50
	$Polygon2D.color = color

func _physics_process(_delta: float) -> void:
	# 마찰력 적용 및 이동
	velocity *= friction
	global_position += velocity
	
	if player == null:
		return
		
	# 자석 시스템 기능 구현
	var dist = global_position.distance_to(player.global_position)
	
	# 플레이어의 자석 범위 모디파이어 변수 반영 (기본값 1.0)
	var final_range = base_magnet_range * Global.upgrade_manager.modifiers.coin_range
	
	if dist < final_range:
		var dir = (player.global_position - global_position).normalized()
		velocity += dir * magnet_speed
		
		# 속도 상한선 제한
		if velocity.length() > max_magnet_speed:
			velocity = velocity.normalized() * max_magnet_speed

func _on_area_entered(area: Node2D) -> void:
	if area.is_in_group("Player"):
		# 플레이어에게 점수와 경험치 지급
		Global.world.experience += exp_val
		Global.world.score += value
		# HTML의 코인 습득 이펙트 연출 구간 (원하는 사운드/파티클 코드를 넣으세요)
		
		queue_free() # 코인 소멸
