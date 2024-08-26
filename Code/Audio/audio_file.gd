class_name AudioFile extends Resource

@export var files:Array[AudioStream]
@export var volume_db := -10.0
@export var min_pitch_scale := 1.0
@export var max_pitch_scale := 1.0
@export var is_music := false
@export var always_play := false

func get_random_audio() -> AudioStream:
	return files.pick_random()
	
func get_random_pitch() -> float:
	return randf_range(min_pitch_scale, max_pitch_scale)
