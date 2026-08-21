# LevelUpUI.gd
extends CanvasLayer

var card_scene : PackedScene = preload("res://card.tscn")

var cards : Array = []
var focused = null
# 카드 씬을 미리 만들어 두고 인스턴스화
var last_reroll
func _ready() -> void:
	hide()
	Global.world.find_child("UpgradeManager").level_up_triggered.connect(_on_level_up_triggered)

func _on_level_up_triggered(upgrades: Array[UpgradeData]) -> void:
	# 기존 카드 제거
	for child in $Cards.get_children():
		child.queue_free()
	cards = []
	focused = null
	if (last_reroll == null || last_reroll + 2 <= Global.upgrade_manager.pick_count ):
		$Reroll.show()
	else:
		$Reroll.hide()
	var i = 0
	show()
	# 3개의 카드 생성
	for upg in upgrades:
		var card : TextureButton = card_scene.instantiate()
		$Cards.add_child(card)
		card.setup(upg) # 카드 테두리 색상, 이름, 설명 세팅
		if i==0:
			card.global_position = Vector2(120.0, 60.0)
		elif i==1:
			card.global_position = Vector2(440.0, 60.0)
		else:
			card.global_position = Vector2(760.0, 60.0)
		cards.append(card)
		card.number = i
		
		# 카드 클릭 시 선택
		card.pressed.connect(func():
			if cards.size() == 3:
				var player = Global.player
				Global.world.find_child("UpgradeManager").apply_upgrade(upg)
				cards = []
				var tween: Tween = create_tween()
				tween.tween_property(card, "global_position", card.global_position+Vector2(0, -120), 0.15)\
				.set_trans(Tween.TRANS_CUBIC)\
				.set_ease(Tween.EASE_OUT)
				tween.tween_property(card, "global_position", card.global_position+Vector2(0, 600), 0.3)\
				.set_trans(Tween.TRANS_QUAD)\
				.set_ease(Tween.EASE_IN)
				$AudioStreamPlayer.play()
				tween.finished.connect(func():
					get_tree().paused = false
					hide()
					)
		)
		i+=1
	cards[0].start(0)
	cards[1].start(0.3)
	cards[2].start(0.6)
func _process(delta: float) -> void:
	if visible && cards.size() == 3:
		var pressed = false
		if Input.is_action_just_pressed("move_left") || Input.is_action_just_pressed("shield_left"):
			if focused == null:
				focused = 0
			else:
				focused-=1
			pressed = true
		if Input.is_action_just_pressed("move_right") || Input.is_action_just_pressed("shield_right"):
			if focused == null:
				focused = 1
			else:
				focused+=1
			pressed = true
		if Input.is_action_just_pressed("move_down") || Input.is_action_just_pressed("shield_down") || Input.is_action_just_pressed("move_up") || Input.is_action_just_pressed("shield_up"):
			if focused == null:
				focused = 2
			pressed = true
		if pressed:
			if focused == -1:
				focused = 2
			elif focused == 3:
				focused = 0
			for card in cards:
				card._on_mouse_exited()
			cards[focused]._on_mouse_entered()
		if Input.is_action_just_pressed("select"):
			if focused != null:
				cards[focused].pressed.emit()


func _on_texture_button_pressed() -> void:
	if (last_reroll == null || last_reroll + 2 <= Global.upgrade_manager.pick_count):
		last_reroll = Global.upgrade_manager.pick_count
		Global.upgrade_manager.trigger_level_up()
