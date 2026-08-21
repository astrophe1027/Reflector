extends Timer

var red_enemy : PackedScene = preload("res://red_enemy.tscn")
var blue_enemy : PackedScene = preload("res://blue_enemy.tscn")
var green_enemy : PackedScene = preload("res://green_enemy.tscn")
var pink_enemy : PackedScene = preload("res://pink_enemy.tscn")
var yellow_enemy : PackedScene = preload("res://yellow_enemy.tscn")
var final_boss : PackedScene = preload("res://final_boss.tscn")

var boss_time : int = 240

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timeout.connect(_on_timeout)
	if Global.world.short_mode:
		boss_time = 180


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_timeout() -> void:
	if Global.world.time_elapsed < boss_time || Global.world.endless_mode:
		if Global.world.hard_mode:
			if get_tree().get_nodes_in_group("Enemy").size() < int(6.0 + 25.0*Global.world.time_elapsed/240.0):
				var spawn_dir = Vector2.from_angle(randf()*TAU).normalized()
				var spawn_position : Vector2 = Global.player.global_position + spawn_dir * 650
				while !(spawn_position.x>0 && spawn_position.x<2500 && spawn_position.y>0 && spawn_position.y<2500):
					spawn_dir = Vector2.from_angle(randf()*TAU)
					spawn_position = Global.player.global_position + spawn_dir * 650
				var enemy_scene : PackedScene
				var random = randf()
				if Global.world.time_elapsed < 60:
					if random < 1.0 - (0.3 * Global.world.time_elapsed/60.0):
						enemy_scene = red_enemy
					else:
						enemy_scene = pink_enemy
				else:
					if random < 1.0 - (0.15 * min(1, (Global.world.time_elapsed - 60.0)/180.0) + 0.4):
						if randf() < 0.6:
							enemy_scene = red_enemy
						else:
							enemy_scene = pink_enemy
					else:
						random = randf()
						if random < 1.0/3.0:
							enemy_scene = blue_enemy
						elif random < 2.0/3.0:
							enemy_scene = green_enemy
						else:
							enemy_scene = yellow_enemy
				var enemy : BaseEnemy = enemy_scene.instantiate()
				Global.world.add_child(enemy)
				enemy.global_position = spawn_position
			start(lerp(1.5, 0.8, Global.world.time_elapsed/240))
		elif Global.world.easy_mode:
			#이지모드
			if get_tree().get_nodes_in_group("Enemy").size() < int(3.0 + 10.0*Global.world.time_elapsed/240.0):
				var spawn_dir = Vector2.from_angle(randf()*TAU).normalized()
				var spawn_position : Vector2 = Global.player.global_position + spawn_dir * 650
				while !(spawn_position.x>0 && spawn_position.x<2500 && spawn_position.y>0 && spawn_position.y<2500):
					spawn_dir = Vector2.from_angle(randf()*TAU)
					spawn_position = Global.player.global_position + spawn_dir * 650
				var enemy_scene : PackedScene
				var random = randf()
				if Global.world.time_elapsed < 60:
					if random < 1.0 - (0.3 * Global.world.time_elapsed/60.0):
						enemy_scene = red_enemy
					else:
						enemy_scene = pink_enemy
				else:
					if random < 1.0 - (0.15 * min(1, (Global.world.time_elapsed - 60.0)/180.0) + 0.4):
						if randf() < 0.7:
							enemy_scene = red_enemy
						else:
							enemy_scene = pink_enemy
					else:
						random = randf()
						if random < 1.0/3.0:
							enemy_scene = blue_enemy
						elif random < 2.0/3.0:
							enemy_scene = green_enemy
						else:
							enemy_scene = yellow_enemy
				var enemy : BaseEnemy = enemy_scene.instantiate()
				Global.world.add_child(enemy)
				enemy.global_position = spawn_position
			start(lerp(2.0, 1.5, Global.world.time_elapsed/240))
		else:
			if get_tree().get_nodes_in_group("Enemy").size() < int(3.0 + 15.0*Global.world.time_elapsed/240.0):
				var spawn_dir = Vector2.from_angle(randf()*TAU).normalized()
				var spawn_position : Vector2 = Global.player.global_position + spawn_dir * 650
				while !(spawn_position.x>0 && spawn_position.x<2500 && spawn_position.y>0 && spawn_position.y<2500):
					spawn_dir = Vector2.from_angle(randf()*TAU)
					spawn_position = Global.player.global_position + spawn_dir * 650
				var enemy_scene : PackedScene
				var random = randf()
				if Global.world.time_elapsed < 60:
					if random < 1.0 - (0.3 * Global.world.time_elapsed/60.0):
						enemy_scene = red_enemy
					else:
						enemy_scene = pink_enemy
				else:
					if random < 1.0 - (0.15 * min(1, (Global.world.time_elapsed - 60.0)/180.0) + 0.4):
						if randf() < 0.7:
							enemy_scene = red_enemy
						else:
							enemy_scene = pink_enemy
					else:
						random = randf()
						if random < 1.0/3.0:
							enemy_scene = blue_enemy
						elif random < 2.0/3.0:
							enemy_scene = green_enemy
						else:
							enemy_scene = yellow_enemy
				var enemy : BaseEnemy = enemy_scene.instantiate()
				Global.world.add_child(enemy)
				enemy.global_position = spawn_position
			start(lerp(2.0, 1.2, Global.world.time_elapsed/240))
	else:
		await wait_for_next_wave()
		if is_inside_tree():
			await get_tree().create_timer(8, false).timeout
			Global.world.save()
			var boss:BaseEnemy = final_boss.instantiate()
			Global.world.add_child(boss)
			boss.global_position = Global.player.global_position + Vector2.RIGHT * 650

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
