@tool
class_name AudioData 
extends Resource

##Volume value betweem 0.0 and 1.0. Values are constrained in code.
@export var master_volume:float = 1.0:
	get:
		if master_volume > 1.0: return 1.0
		elif master_volume < 0.0: return 0.0
		return master_volume
	set(_value):
		master_volume = _value
		if master_volume > 1.0: master_volume = 1.0
		elif master_volume < 0.0: master_volume = 0.0
##Volume value betweem 0.0 and 1.0. Values are constrained in code.
@export var music_volume :float = 1.0:
	get:
		if music_volume > 1.0: return 1.0
		elif music_volume < 0.0: return 0.0
		return music_volume
	set(_value):
		music_volume = _value
		if music_volume > 1.0: music_volume = 1.0
		elif music_volume < 0.0: music_volume = 0.0
##Volume value betweem 0.0 and 1.0. Values are constrained in code.
@export var sfx_volume :float = 1.0:
	get:
		if sfx_volume > 1.0: return 1.0
		elif sfx_volume < 0.0: return 0.0
		return sfx_volume
	set(_value):
		sfx_volume = _value
		if sfx_volume > 1.0: sfx_volume = 1.0
		elif sfx_volume < 0.0: sfx_volume = 0.0
##Audio Files can be inserted manualy or can be retreived automatically on runtime.
@export var audio_files:Array[AudioFile]


func get_audio_file(_id:String = "") -> AudioFile:
	for file in audio_files:
		if file.id == _id:
			return file
	push_error("AudioFile ", _id, " not present in the AudioData resource.")
	return null


func add_audio_file(_af:AudioFile = null) -> bool:
	var result:bool = true
	for file in audio_files:
		if file.id == _af.id:
			result = false
			break
	
	if result:
		audio_files.append(_af.duplicate())
	else:
		push_warning("AudioFile ", _af.id, " not appended to AudioData as it is already present.")
	
	return result