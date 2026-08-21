extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_mouse_entered() -> void:
	modulate = Color(0.588, 0.588, 0.588, 1.0)


func _on_mouse_exited() -> void:
	modulate = Color(1.0, 1.0, 1.0, 1.0)
