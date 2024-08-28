class_name SHSlider 
extends HSlider

@export var bus_name :String = ""

func _ready() -> void:
	Audio.VolumesUpdated.connect(_update_value)

func _update_value() -> void:
	if bus_name:
		var bus_i :int = AudioServer.get_bus_index(bus_name)
		value = db_to_linear(AudioServer.get_bus_volume_db(bus_i))
