extends Node

const AUDIO_STAGE = preload("res://addons/AudioBySymbol/Scenes/Audio/audio_stage.tscn")
const DEFAULT = preload("res://addons/AudioBySymbol/Data/Audio/default.tres")
const MIN_DB := -60.0
const MAX_DB := 0.0

var audio_stage:AudioStage
var audio_pool:Array = []
var music:SAudioStreamPlayer
var audio_check_timer := 0.0:
	set(_value):
		audio_check_timer = _value
		if audio_check_timer >= delay:
			audio_check_timer = 0.0
			_clear_audio_pool()
var delay := 60.0

signal VolumesUpdated()

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	audio_stage = AUDIO_STAGE.instantiate() as AudioStage
	add_child(audio_stage)
	if AudioServer.get_bus_index("Music") != 1: 
		AudioServer.add_bus(1)
		AudioServer.set_bus_name(1, "Music")
	if AudioServer.get_bus_index("SFX") != 2: 
		AudioServer.add_bus(2)
		AudioServer.set_bus_name(2, "SFX")

func _process(_delta) -> void:
	audio_check_timer += _delta

func _clear_audio_pool() -> void:
	var x := 0
	var to_clear := []
	while x < audio_pool.size():
		if audio_pool[x] != null and !audio_pool[x].playing:
			to_clear.append(x)
		x += 1
	if !to_clear.is_empty():
		for i:int in to_clear:
			if i < audio_pool.size():
				var temp = audio_pool.pop_at(i)
				if temp != null:
					temp.queue_free.call_deferred()

func play(audio:AudioFile = null, _is_2d := false) -> SAudioStreamPlayer:
	var new_player:SAudioStreamPlayer = SAudioStreamPlayer.new()
	if audio != null:
		new_player.set_stream(audio.get_random_audio())
		if audio.is_music:
			new_player.bus = "Music"
			if music != null: music.stop()
			music = new_player
		else: new_player.bus = "SFX"
		#print("Audio in bus ", new_player.bus)
		new_player.volume_db = audio.volume_db
		if audio.random_pitch:
			new_player.pitch_scale = audio.get_random_pitch()
	if new_player.stream != null:
		audio_stage.add_child(new_player)
		new_player.AudioExiting.connect(_freed_audio)
		audio_pool.append(new_player)
		if audio.is_music: new_player.process_mode = PROCESS_MODE_ALWAYS
		elif audio.always_play: new_player.process_mode = PROCESS_MODE_ALWAYS
		new_player.play()
	return new_player

func _update_audio_volume(bus_name := "Master", percent := 1.0) -> void:
	if percent > -0.1 and percent <= 1.0:
		var bus_index:int = AudioServer.get_bus_index(bus_name)
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(percent))

func reset_volumes() -> void:
	_update_audio_volume("Master", DEFAULT.master_volume)
	_update_audio_volume("Music", DEFAULT.music_volume)
	_update_audio_volume("SFX", DEFAULT.sfx_volume)
	VolumesUpdated.emit()

func set_volumes(_master:= 1.0, _music := 1.0, _sfx := 1.0) -> void:
	_update_audio_volume("Master", _master)
	_update_audio_volume("Music", _music)
	_update_audio_volume("SFX", _sfx)
	VolumesUpdated.emit()

func _freed_audio(_audio) -> void:
	var x := 0
	var found := false
	while x < audio_pool.size():
		if _audio == audio_pool[x]:
			found = true
			break
		x += 1
	if found:
		var _temp = audio_pool.pop_at(x)
		_temp.queue_free.call_deferred()
