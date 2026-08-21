extends Node

var world:Node
var upgrade_manager:UpgradeManager
var player:Area2D
var world_scene:PackedScene = preload("res://world.tscn")
var save:Dictionary
var is_saved:bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start(difficulty: int, short:bool, endless:bool) -> void:
	Global.is_saved = false
	world = null
	var map = world_scene.instantiate()
	map.easy_mode = difficulty == 1
	map.hard_mode = difficulty == 3
	map.short_mode = short
	map.endless_mode = endless
	get_tree().change_scene_to_node(map)
