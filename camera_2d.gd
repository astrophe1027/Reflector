extends Camera2D

var shake_strength: float = 0.0
var shake_tween: Tween = null

@onready var player : Area2D = Global.player

func _ready() -> void:
	global_position = player.global_position
	
func _process(_delta: float) -> void:
	if shake_strength > 0.0:
		# 1. 흔들리는 동안 오프셋을 무작위로 변경
		offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
	else:
		# 2. 흔들림이 끝나면 확실하게 0으로 고정
		offset = Vector2.ZERO

func _physics_process(delta: float) -> void:
	global_position = global_position.lerp(player.global_position, 0.7)
	
# 🎯 호출하는 함수 (기본 0.3초 동안 흔들리고 완벽히 멈춤)
func apply_shake(strength: float = 10.0, duration: float = 0.3) -> void:
	shake_strength = strength
	
	# 이미 진행 중인 트윈이 있다면 취소 (연속 피격 대비)
	if shake_tween and shake_tween.is_running():
		shake_tween.kill()
		
	shake_tween = create_tween()
	
	# 지정한 duration(시간) 동안 shake_strength를 0.0으로 줄입니다.
	shake_tween.tween_property(self, "shake_strength", 0.0, duration)
