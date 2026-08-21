extends AudioStreamPlayer

var normal_musics = [preload("res://assets/sound/bgm/Three Red Hearts - Go (No Vocal).ogg"),
preload("res://assets/sound/bgm/Abandoned Hopes.wav"), preload("res://assets/sound/bgm/Crimson Drive.wav")]
var hard_musics = [preload("res://assets/sound/bgm/hard_mode/Mecha Collection.wav"), preload("res://assets/sound/bgm/hard_mode/Three Red Hearts - Pixel War 1.ogg")]
var boss_musics = [preload("res://assets/sound/bgm/boss/Three Red Hearts - Out of Time.ogg"), preload("res://assets/sound/bgm/hard_mode/Three Red Hearts - Pixel War 1.ogg")]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(1, false).timeout
	if Global.world.hard_mode:
		stream = hard_musics[0]
	else:
		stream = normal_musics[0]
	play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func boss() -> void:
	var tween = create_tween()
	tween.tween_property(self, "volume_db", -40.0, 1).set_ease(Tween.EASE_IN)
	tween.finished.connect(func():
		stop()
		stream = boss_musics[0]
		volume_db = 0
		play()
		)
	

func _on_finished() -> void:
	if get_tree().get_first_node_in_group("Boss") != null:
		stream = boss_musics.pick_random()
	elif Global.world.hard_mode:
		stream = hard_musics.pick_random()
	else:
		stream = normal_musics.pick_random()
	play()
