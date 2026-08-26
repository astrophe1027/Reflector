extends Control

var red_enemy : PackedScene = preload("res://red_enemy.tscn")
var blue_enemy : PackedScene = preload("res://blue_enemy.tscn")
var green_enemy : PackedScene = preload("res://green_enemy.tscn")
var pink_enemy : PackedScene = preload("res://pink_enemy.tscn")
var yellow_enemy : PackedScene = preload("res://yellow_enemy.tscn")
var final_boss : PackedScene = preload("res://final_boss.tscn")
signal input_received(action_name: StringName)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func spawn(enemy_scene:PackedScene, angle:float) -> void:
	var enemy : BaseEnemy = enemy_scene.instantiate()
	Global.world.add_child(enemy)
	var spawn_position : Vector2 = Global.player.global_position + Vector2.from_angle(angle*(lerp(-0.2, 0.2, randf())+1)).normalized()*650
	enemy.global_position = spawn_position
func show_text(text:String) -> void:
	$Label.text = ""
	for char in text:
		$Label.text = $Label.text + char
		if char == " ":
			await get_tree().create_timer(0.17, false, true).timeout
		else:
			await get_tree().create_timer(0.06, false, true).timeout
	await get_tree().create_timer(1.1, false, true).timeout
	
func _input(event: InputEvent) -> void:
	# 등록된 Input Map 액션 중 방금 눌린 것이 있는지 확인
	for action in InputMap.get_actions():
		if event.is_action_pressed(action) and not event.is_echo():
			input_received.emit(action)
			
func wait_for_all_inputs(action_names: Array[StringName]) -> void:
	# 중복을 제거한 액션 목록 생성
	var remaining: Dictionary = {}
	for action in action_names:
		remaining[action] = true

	# 모든 액션이 눌릴 때까지 시그널을 await
	while not remaining.is_empty():
		var pressed_action: StringName = await input_received
		
		if remaining.has(pressed_action):
			remaining.erase(pressed_action)
			print("확인된 액션: ", pressed_action, " (남은 수: ", remaining.size(), ")")
			
func wait_for_next_wave() -> void:
	var enemies = get_tree().get_nodes_in_group("Enemy")
	if enemies.is_empty():
		await get_tree().create_timer(1).timeout
		return
	while true:
		if is_inside_tree():
			var current_enemies = get_tree().get_nodes_in_group("Enemy")
			if current_enemies.is_empty():
				await get_tree().create_timer(1).timeout
				break
			await current_enemies[0].tree_exited
		else:
			return
			
func tutorial() -> void:
	await get_tree().create_timer(1.0, false, true).timeout
	show()
	await show_text("안녕하세요. Reflector에 오신걸 환영합니다.")
	await show_text("이 게임은 처음이신거 같군요.")
	$Space.show()
	await wait_for_all_inputs(["select"])
	$Space.hide()
	await show_text("우선 조작부터 설명드리겠습니다.")
	await show_text("이 게임은 마우스 없이 진행됩니다.")
	await show_text("왼손은 WASD에, 오른손은 방향키에 올려주세요.")
	$Space.show()
	await wait_for_all_inputs(["select"])
	$Space.hide()
	await show_text("WASD를 이용해 상하좌우로 움직일 수 있습니다.")
	await wait_for_all_inputs(["move_up", "move_down", "move_left", "move_right"])
	await show_text("좋습니다.")
	await show_text("방향키를 이용해 원하는 방향으로 방패를 들 수 있습니다.")
	await wait_for_all_inputs(["shield_up", "shield_down", "shield_left", "shield_right"])
	$Arrow.show()
	await show_text("방패에는 게이지가 존재합니다. \n잔량에 따라 방패 색도 바뀝니다.")
	await get_tree().create_timer(0.3, false, true).timeout
	await show_text("너무 오래쓰지 않도록 조심하세요.")
	$Space.show()
	await wait_for_all_inputs(["select"])
	$Space.hide()
	$Arrow.global_position = Vector2(285, 26)
	await show_text("당신의 체력입니다.")
	$Space.show()
	await wait_for_all_inputs(["select"])
	$Space.hide()
	$Arrow.global_position = Vector2(290, 86)
	await show_text("다음 업그레이드까지 모을 경험치입니다.")
	$Space.show()
	await wait_for_all_inputs(["select"])
	$Space.hide()
	$Arrow.hide()
	await show_text("경험치를 모으면 업그레이드를 선택할 수 있게 됩니다.")
	Global.world._level_up()
	await show_text("새로운 업그레이드는 마음에 드시나요?")
	$Space.show()
	await wait_for_all_inputs(["select"])
	$Space.hide()
	await show_text("좋습니다.")
	await show_text("이제 전투에 관한 부분입니다.")
	await show_text("테스트를 위해 적을 하나 소환하겠습니다.")
	await show_text("적은 플레이어를 향해 총알을 발사합니다.")
	var enemy:BaseEnemy = red_enemy.instantiate()
	Global.world.add_child(enemy)
	enemy.global_position = Global.player.global_position + Vector2.RIGHT * 650
	await show_text("당신은 그저, 주어진 방패로 튕겨내면 됩니다.")
	await wait_for_next_wave()
	await show_text("잘 하셨습니다.")
	await show_text("이번에는 더 많고 다양한 적으로 가보겠습니다.")
	spawn(red_enemy, PI/2+3)
	spawn(red_enemy, 3*PI/2+3)
	spawn(pink_enemy, 3)
	spawn(pink_enemy, 5)
	await wait_for_next_wave()
	await show_text("훌룡합니다.")
	await show_text("이외에도 적들의 종류는 다양합니다.")
	spawn(blue_enemy, 0)
	await wait_for_next_wave()
	spawn(green_enemy, 0)
	await wait_for_next_wave()
	spawn(yellow_enemy, 0)
	await wait_for_next_wave()
	await show_text("환상적이군요.")
	await show_text("이제 튜토리얼은 끝났습니다.")
	await show_text("가서 마음껏 즐기시면 됩니다.")
	Global.world.game_clear()


	
