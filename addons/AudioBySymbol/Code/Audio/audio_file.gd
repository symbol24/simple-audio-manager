class_name AudioFile extends Resource

##Import your own audio files and add them to the files list. Note, if only 1 file rpesent, then no random sounds.
@export var files:Array[AudioStream]
##Default decibel volume is set to -10, please avoid going over 0, and adjust the other files for better balance.
@export var volume_db :float = -10.0
##Pitch allows for variation in sounds.
@export var min_pitch_scale :float = 1.0
##Pitch allows for variation in sounds.
@export var max_pitch_scale :float = 1.0
##Setting to true allows the audio to be pitched vetween the min and max.
@export var random_pitch :bool = true
##If set to true, AudioStream will play on the Music bus. Music continues to play when tree is paused.
@export var is_music :bool = false
##If set to true, AudioStream will continue to play when tree is paused.
@export var always_play :bool = false

func get_random_audio() -> AudioStream:
	return files.pick_random()
	
func get_random_pitch() -> float:
	return randf_range(min_pitch_scale, max_pitch_scale)
