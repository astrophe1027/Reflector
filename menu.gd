extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		if !get_tree().paused && !visible:
			get_tree().paused = true
			visible = true
		elif get_tree().paused && visible:
			get_tree().paused = false
			visible = false

func _notification(what: int) -> void:
	match what:
		# 게임 창이 포커스를 잃었을 때 (탭 전환, 모바일 브라우저 최소화 등)
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			if !get_tree().paused && !visible:
				get_tree().paused = true
				visible = true
				
func _on_return_pressed() -> void:
	if get_tree().paused && visible:
		get_tree().paused = false
		visible = false


func _on_retry_pressed() -> void:
	Global.retry_save = {
		"easy_mode": Global.world.easy_mode,
		"hard_mode": Global.world.hard_mode,
		"short_mode": Global.world.short_mode,
		"endless_mode": Global.world.endless_mode,
		"tutorial": Global.world.tutorial
	}
	Global.is_retry = true
	if get_tree().paused && visible:
		get_tree().paused = false
		visible = false
	var tween:Tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(Global.world.find_child("UI").find_child("ColorRect"), "color:a", 1, 1).set_ease(Tween.EASE_IN)
	tween.tween_property(Global.world.find_child("BGM"), "volume_db", -40.0, 1).set_ease(Tween.EASE_IN)
	tween.finished.connect(func():
		propagate_call("set_process", [false])
		propagate_call("set_physics_process", [false])
		process_mode = Node.PROCESS_MODE_DISABLED
		get_tree().paused = true
		await get_tree().create_timer(0.1).timeout
		get_tree().reload_current_scene.call_deferred()
		)


func _on_main_pressed() -> void:
	if get_tree().paused && visible:
		get_tree().paused = false
		visible = false
	var tween:Tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(Global.world.find_child("UI").find_child("ColorRect"), "color:a", 1, 1).set_ease(Tween.EASE_IN)
	tween.tween_property(Global.world.find_child("BGM"), "volume_db", -40.0, 1).set_ease(Tween.EASE_IN)
	tween.finished.connect(func():
		propagate_call("set_process", [false])
		propagate_call("set_physics_process", [false])
		process_mode = Node.PROCESS_MODE_DISABLED
		get_tree().paused = true
		await get_tree().create_timer(0.1).timeout
		get_tree().change_scene_to_file.call_deferred("res://main.tscn")
		)


func _on_setting_button_pressed() -> void:
	$Settings.show()
