extends Node

var world:Node
var upgrade_manager:UpgradeManager
var player:Area2D
var world_scene:PackedScene = preload("res://world.tscn")
var save:Dictionary
var is_saved:bool = false

var time:int = 0
var score:int = 0
var level:int = 0

var retry_save:Dictionary
var is_retry:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start(difficulty: int, short:bool, endless:bool) -> void:
	Global.is_saved = false
	Global.is_retry = false
	world = null
	var map = world_scene.instantiate()
	map.easy_mode = difficulty == 1
	map.hard_mode = difficulty == 3
	map.short_mode = short
	map.endless_mode = endless
	get_tree().change_scene_to_node(map)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("full_screen"):
		var mode := DisplayServer.window_get_mode()
		var is_window: bool = mode != DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if is_window else DisplayServer.WINDOW_MODE_WINDOWED)
