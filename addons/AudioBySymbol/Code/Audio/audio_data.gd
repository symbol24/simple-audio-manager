@tool
class_name AudioData extends Resource

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
