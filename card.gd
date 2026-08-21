extends TextureButton

var data : UpgradeData
var number:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	
func start(time: float) -> void:
	await get_tree().create_timer(time).timeout
	show()
	# 1. 원래 가야 할 최종 목표 위치 저장
	var target_pos: Vector2 = global_position
	var target_rot: float = 0.0
	
	# 2. 시작 위치 및 시작 회전 각도 설정 (왼쪽 위 오프셋)
	# x는 왼쪽으로 -200px, y는 위쪽으로 -400px 이동된 위치에서 출발
	global_position = target_pos + Vector2(-500, -300)
	rotation_degrees = 50

	# 3. Tween 생성 및 연출 시작
	var tween = create_tween().set_parallel(true)
	
	# A. 위치 이동 애니메이션 (위쪽/왼쪽 ➔ 원래 위치)
	tween.tween_property(self, "global_position", target_pos, 2)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)
	# B. 회전 애니메이션 (50도 ➔ 0도)
	tween.tween_property(self, "rotation_degrees", target_rot, 1.2)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func setup(upgrade_data : UpgradeData) -> void:
	data = upgrade_data
	$Description.text = upgrade_data.description
	$Name.text = upgrade_data.name
	$TextureRect.texture = upgrade_data.image
	if data.tier == UpgradeData.Tier.UNIQUE:
		texture_normal = preload("res://assets/card_2.png")
	elif data.tier == UpgradeData.Tier.LEGENDARY:
		texture_normal = preload("res://assets/card_3.png")


func _on_mouse_entered() -> void:
	for card in get_parent().get_children():
		card.modulate = Color(0.588, 0.588, 0.588, 1.0)
	get_parent().get_parent().focused = number
	modulate = Color(1.0, 1.0, 1.0, 1.0)


func _on_mouse_exited() -> void:
	modulate = Color(0.588, 0.588, 0.588, 1.0)
