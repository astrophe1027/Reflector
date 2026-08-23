extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#소리 조절
func _on_h_slider_value_changed(value: float) -> void:
	$Sound/Value.text = str(int(value))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value/100.0)-8)


func _on_setting_back_pressed() -> void:
	hide()
