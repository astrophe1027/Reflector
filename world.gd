extends Node

var player : Area2D = null

signal exp_changed
signal level_up

var easy_mode:bool = false
var hard_mode:bool = false

var short_mode:bool = false
var endless_mode:bool = false

var score:int = 0

var player_level = 1
var next_exp : int = 100
var experience : int = 0:
	set(value):
		experience = value
		while experience >= next_exp:
			experience -= next_exp
			player_level += 1
			if hard_mode:
				next_exp = floor(next_exp * 1.3 + 40)
			elif easy_mode:
				next_exp = floor(next_exp * 1.1 + 30)
			else:
				next_exp = floor(next_exp * 1.2 + 30)
			_level_up()
		exp_changed.emit()
			
var time_elapsed : float = 0

func _init() -> void:
	Global.world = self
	if Global.is_saved:
		player_level = Global.save.level
		next_exp = Global.save.next_exp
		experience = Global.save.exp
		time_elapsed = Global.save.time
		easy_mode = Global.save.easy_mode
		hard_mode = Global.save.hard_mode
		short_mode = Global.save.short_mode
		endless_mode = Global.save.endless_mode
	if Global.is_retry:
		easy_mode = Global.retry_save.easy_mode
		hard_mode = Global.retry_save.hard_mode
		short_mode = Global.retry_save.short_mode
		endless_mode = Global.retry_save.endless_mode
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = false
	if Global.is_saved:
		player_level = Global.save.level
		next_exp = Global.save.next_exp
		experience = Global.save.exp
		time_elapsed = Global.save.time
		easy_mode = Global.save.easy_mode
		hard_mode = Global.save.hard_mode
		short_mode = Global.save.short_mode
		endless_mode = Global.save.endless_mode
		exp_changed.emit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	time_elapsed += 1.0/60.0
	
func _level_up():
	Global.world.score += 3000
	level_up.emit()
	$LevelUp.play()
	Global.player.current_health = min(Global.player.max_health, Global.player.current_health+10)


func _on_player_died() -> void:
	Global.time = int(time_elapsed)
	Global.level = player_level
	Global.score = score
	await get_tree().create_timer(2).timeout
	var tween:Tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property($UI.find_child("ColorRect"), "color:a", 1, 1).set_ease(Tween.EASE_IN)
	tween.tween_property($BGM, "volume_db", -40.0, 1).set_ease(Tween.EASE_IN)
	tween.finished.connect(func():
		propagate_call("set_process", [false])
		propagate_call("set_physics_process", [false])
		process_mode = Node.PROCESS_MODE_DISABLED
		get_tree().paused = true
		await get_tree().create_timer(0.1).timeout
		get_tree().change_scene_to_file.call_deferred("res://game_over.tscn")
		)
	
func game_clear() -> void:
	Global.time = int(time_elapsed)
	Global.level = player_level
	Global.score = score
	await get_tree().create_timer(6).timeout
	var tween:Tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property($UI.find_child("ColorRect"), "color:a", 1, 1).set_ease(Tween.EASE_IN)
	tween.tween_property($BGM, "volume_db", -40.0, 1).set_ease(Tween.EASE_IN)
	tween.finished.connect(func():
		propagate_call("set_process", [false])
		propagate_call("set_physics_process", [false])
		process_mode = Node.PROCESS_MODE_DISABLED
		get_tree().paused = true
		await get_tree().create_timer(0.1).timeout
		get_tree().change_scene_to_file.call_deferred("res://game_clear.tscn")
		)

func save() -> void:
	Global.save = {
		"modifiers": Global.upgrade_manager.modifiers.duplicate(true),
		"health": Global.player.current_health,
		"max_health": Global.player.max_health,
		"shield_size": Global.player.find_child("Shield").scale.y,
		"traits": Global.upgrade_manager.traits.duplicate(true),
		"applied_one_time_upgrades": Global.upgrade_manager.applied_one_time_upgrades,
		"level": player_level,
		"time": time_elapsed,
		"next_exp": next_exp,
		"exp": experience,
		"easy_mode": easy_mode,
		"hard_mode": hard_mode,
		"short_mode": short_mode,
		"endless_mode": endless_mode
	}
	Global.is_saved = true
