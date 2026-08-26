extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_easy_button_pressed() -> void:
	$SelectSound.play()
	var tween:Tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property($ColorRect, "color:a", 1, 1).set_ease(Tween.EASE_IN)
	tween.tween_property($BGM, "volume_db", -40.0, 1).set_ease(Tween.EASE_IN)
	tween = create_tween()
	tween.tween_property($Select/Easy, "global_position", $Select/Easy.global_position+Vector2(0, -120), 0.2)\
	.set_trans(Tween.TRANS_CUBIC)\
	.set_ease(Tween.EASE_OUT)
	tween.tween_property($Select/Easy, "global_position", $Select/Easy.global_position+Vector2(0, 600), 0.3)\
	.set_trans(Tween.TRANS_QUAD)\
	.set_ease(Tween.EASE_IN) 
	tween.finished.connect(func():
		$Select/Easy.hide())
	await get_tree().create_timer(1).timeout
	if $Select/TabBar.current_tab == 1:
		Global.start(1, true, false)
	elif $Select/TabBar.current_tab == 2:
		Global.start(1, false, true)
	else:
		Global.start(1, false, false)


func _on_normal_button_pressed() -> void:
	$SelectSound.play()
	var tween:Tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property($ColorRect, "color:a", 1, 1).set_ease(Tween.EASE_IN)
	tween.tween_property($BGM, "volume_db", -40.0, 1).set_ease(Tween.EASE_IN)
	tween = create_tween()
	tween.tween_property($Select/Normal, "global_position", $Select/Normal.global_position+Vector2(0, -120), 0.15)\
	.set_trans(Tween.TRANS_CUBIC)\
	.set_ease(Tween.EASE_OUT)
	tween.tween_property($Select/Normal, "global_position", $Select/Normal.global_position+Vector2(0, 600), 0.3)\
	.set_trans(Tween.TRANS_QUAD)\
	.set_ease(Tween.EASE_IN) 
	tween.finished.connect(func():
		$Select/Normal.hide())
	await get_tree().create_timer(1).timeout
	if $Select/TabBar.current_tab == 1:
		Global.start(2, true, false)
	elif $Select/TabBar.current_tab == 2:
		Global.start(2, false, true)
	else:
		Global.start(2, false, false)


func _on_hard_button_pressed() -> void:
	$SelectSound.play()
	var tween:Tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property($ColorRect, "color:a", 1, 1).set_ease(Tween.EASE_IN)
	tween.tween_property($BGM, "volume_db", -40.0, 1).set_ease(Tween.EASE_IN)
	tween = create_tween()
	tween.tween_property($Select/Hard, "global_position", $Select/Hard.global_position+Vector2(0, -120), 0.15)\
	.set_trans(Tween.TRANS_CUBIC)\
	.set_ease(Tween.EASE_OUT)
	tween.tween_property($Select/Hard, "global_position", $Select/Hard.global_position+Vector2(0, 600), 0.3)\
	.set_trans(Tween.TRANS_QUAD)\
	.set_ease(Tween.EASE_IN)
	tween.finished.connect(func():
		$Select/Hard.hide())
	await get_tree().create_timer(1).timeout
	if $Select/TabBar.current_tab == 1:
		Global.start(3, true, false)
	elif $Select/TabBar.current_tab == 2:
		Global.start(3, false, true)
	else:
		Global.start(3, false, false)
	
var tweens = []
func _on_button_pressed() -> void:
	$SelectSound.play()
	$Select.show()
	for a in tweens:
		a.kill()
	var i = 0
	for card : Control in $Select.get_children():
		card.hide()
		if !card is TextureButton && !card is TabBar:
			match i:
				0:card.position=Vector2(158, 131)
				1:card.position=Vector2(445, 131)
				2:card.position=Vector2(737, 131)
			card.rotation=0
			i+=1
	for card : Control in $Select.get_children():
		if !card is TextureButton && !card is TabBar:
			card.show()
			var target_pos = card.global_position
			card.global_position = target_pos + Vector2(-500, -300)
			card.rotation_degrees = 50
			var tween = create_tween().set_parallel(true)
			tweens.append(tween)
			# A. 위치 이동 애니메이션 (위쪽/왼쪽 ➔ 원래 위치)
			tween.tween_property(card, "global_position", target_pos, 2)\
				.set_trans(Tween.TRANS_EXPO)\
				.set_ease(Tween.EASE_OUT)
			# B. 회전 애니메이션 (50도 ➔ 0도)
			tween.tween_property(card, "rotation_degrees", 0, 1.2)\
				.set_trans(Tween.TRANS_CUBIC)\
				.set_ease(Tween.EASE_OUT)
			#$Card.play()
			await get_tree().create_timer(0.3).timeout
	$Select.find_child("Back").show()
	$Select.find_child("TabBar").show()



func _on_button_2_pressed() -> void:
	var tween:Tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property($ColorRect, "color:a", 1, 1).set_ease(Tween.EASE_IN)
	tween.tween_property($BGM, "volume_db", -40.0, 1).set_ease(Tween.EASE_IN)
	tween = create_tween()
	tween.tween_property($Select/Hard, "global_position", $Select/Hard.global_position+Vector2(0, -120), 0.15)\
	.set_trans(Tween.TRANS_CUBIC)\
	.set_ease(Tween.EASE_OUT)
	tween.tween_property($Select/Hard, "global_position", $Select/Hard.global_position+Vector2(0, 600), 0.3)\
	.set_trans(Tween.TRANS_QUAD)\
	.set_ease(Tween.EASE_IN)
	tween.finished.connect(func():
		pass
		)
	await get_tree().create_timer(1).timeout
	Global.tutorial()



func _on_credit_back_pressed() -> void:
	$SelectSound.play()
	$Credit.hide()
	
func _on_credit_button_pressed() -> void:
	$SelectSound.play()
	$Credit.show()

func _on_setting_button_pressed() -> void:
	$SelectSound.play()
	$Settings.show()
	
func _on_setting_back_pressed() -> void:
	$SelectSound.play()
	$Settings.hide()


func _on_quit_button_pressed() -> void:
	$SelectSound.play()
	get_tree().quit()


func _on_back_pressed() -> void:
	$SelectSound.play()
	$Select.hide()
