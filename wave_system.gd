extends Node

var red_enemy: PackedScene = preload("res://red_enemy.tscn")
var blue_enemy: PackedScene = preload("res://blue_enemy.tscn")
var green_enemy: PackedScene = preload("res://green_enemy.tscn")
var yellow_enemy: PackedScene = preload("res://yellow_enemy.tscn")
var pink_enemy: PackedScene = preload("res://pink_enemy.tscn")
var boss: PackedScene = preload("res://buki.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#start_wave()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn(enemy_scene:PackedScene, angle:float) -> void:
	var enemy : BaseEnemy = enemy_scene.instantiate()
	Global.world.add_child(enemy)
	var spawn_position : Vector2 = Global.player.global_position + Vector2.from_angle(angle*(lerp(-0.2, 0.2, randf())+1)).normalized()*650
	enemy.global_position = spawn_position


func wait_for_next_wave() -> void:
	var enemies = get_tree().get_nodes_in_group("Enemy")
	if enemies.is_empty():
		await get_tree().create_timer(1).timeout
		return
	while true:
		var current_enemies = get_tree().get_nodes_in_group("Enemy")
		if current_enemies.is_empty():
			await get_tree().create_timer(1).timeout
			break
		await current_enemies[0].tree_exited

func start_wave() -> void:
	await get_tree().create_timer(2).timeout
	spawn(red_enemy, 1)
	await wait_for_next_wave()
	for i in range(4):
		spawn(red_enemy, i*PI/2+3)
		await get_tree().create_timer(0.1).timeout
	await wait_for_next_wave()
	for i in range(4): 
		spawn(pink_enemy, i*(PI/2+0.3)+1)
	await wait_for_next_wave()
	spawn(red_enemy, PI/2+3)
	spawn(red_enemy, 3*PI/2+3)
	spawn(red_enemy, 4)
	spawn(pink_enemy, 3)
	spawn(pink_enemy, 5)
	await wait_for_next_wave()
	
	spawn(boss, PI/4)
	
