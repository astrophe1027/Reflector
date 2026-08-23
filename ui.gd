extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.world.exp_changed.connect(_on_world_exp_changed)
	var tween = get_tree().create_tween()
	tween.tween_property($ColorRect, "color:a", 0.0, 1.0)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$TimeLabel.text = "생존 시간: "+str(int(Global.world.time_elapsed))+"초"
	$shieldBar.max_value = Global.player.find_child("Shield").max_gauge
	$shieldBar.value = Global.player.find_child("Shield").current_gauge
	if is_instance_valid(get_tree().get_first_node_in_group("Boss")):
		if !$BossBar.visible:
			$BossBar.show()
			$BossBar.max_value = float(get_tree().get_first_node_in_group("Boss").max_hp)
		$BossBar.value = get_tree().get_first_node_in_group("Boss").hp
	else:
		if $BossBar.visible:
			$BossBar.hide()
	$ScoreLabel.text = "점수: "+str(Global.world.score)
	
func _on_player_health_changed(current_health: int, max_health: int) -> void:
	$HpBar.value = current_health
	$HpBar.max_value = max_health
	$HpLabel.text = str(current_health) + "/" + str(max_health)


func _on_player_hit() -> void:
	var tween = create_tween()
	
	# 초기 투명도 설정
	$HitEffect.color.a = 0.6 
	
	# EASE_OUT 및 QUAD 속성 적용
	tween.tween_property($HitEffect, "color:a", 0.0, 0.5)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
		
	#if !$HitEffect.visible:
	#	$HitEffect.show()
	#	await get_tree().create_timer(0.3).timeout
	#	$HitEffect.hide()

func _on_world_exp_changed() -> void:
	$ExpBar.value = Global.world.experience
	$ExpBar.max_value = Global.world.next_exp
	$ExpLabel.text = str(Global.world.experience) + "/" + str(Global.world.next_exp)
	$LevelLabel.text = str(Global.world.player_level) + "Lv"
