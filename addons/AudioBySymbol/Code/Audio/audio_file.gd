class_name AudioFile 
extends Resource


##An ID that is used by the auto load to find the proper audio file.
@export var id:String = ""

##Import your own audio files and add them to the files list. Note, if only 1 file present, then no random sounds.
@export var files:Array[AudioStream]

##Default decibel volume is set to -10, please avoid going over 0, and adjust the other files for better balance.
@export var volume_db :float = -10.0

##Pitch allows for variation in sounds. If both min and max are 1, no pitch change.
@export var min_pitch_scale :float = 1.0

##Pitch allows for variation in sounds. If both min and max are 1, no pitch change.
@export var max_pitch_scale :float = 1.0

##If set to true, AudioStream will play on the Music bus. Music continues to play when tree is paused.
@export var is_music :bool = false

##If set to true, AudioStream will continue to play when tree is paused.
@export var always_play :bool = false

##If set to true, AudioStream will not play if another is currently playing. (ignores dead/zombie AudioStreams waiting to be cleaned up)
@export var is_unique:bool = false

func get_random_audio() -> AudioStream:
	return files.pick_random()
	
func get_random_pitch() -> float:
	return randf_range(min_pitch_scale, max_pitch_scale)
