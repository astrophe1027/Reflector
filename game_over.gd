extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = false
	$ColorRect.color.a = 1
	var tween:Tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property($ColorRect, "color:a", 0, 2).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(0.5).timeout
	$BGM.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_retry_pressed() -> void:
	var tween:Tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property($ColorRect, "color:a", 1, 1).set_ease(Tween.EASE_IN)
	tween.tween_property($BGM, "volume_db", -40.0, 1).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(1).timeout
	if Global.is_saved:
		get_tree().change_scene_to_file("res://world.tscn")
	else:
		get_tree().change_scene_to_file("res://main.tscn")
