extends Node

const AUDIO_STAGE := preload("res://addons/AudioBySymbol/Scenes/Audio/audio_stage.tscn")
const DEFAULT := preload("res://addons/AudioBySymbol/Data/Audio/default.tres")
const MIN_DB := -60.0
const MAX_DB := 0.0

var audio_stage:AudioStage
var audio_pool:Array = []
var music:Node
var audio_check_timer :float = 0.0:
	set(_value):
		audio_check_timer = _value
		if audio_check_timer >= delay:
			audio_check_timer = 0.0
			_clear_audio_pool()
var delay :float = 60.0

signal VolumesUpdated()

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	
	#Creates the audio stage as a child of the autoload.
	audio_stage = AUDIO_STAGE.instantiate() as AudioStage
	add_child(audio_stage)
	
	#Creates audio Bus for Music and SFX if they are not already present
	if AudioServer.get_bus_index("Music") != 1: 
		AudioServer.add_bus(1)
		AudioServer.set_bus_name(1, "Music")
	if AudioServer.get_bus_index("SFX") != 2: 
		AudioServer.add_bus(2)
		AudioServer.set_bus_name(2, "SFX")

func _process(_delta:float) -> void:
	audio_check_timer += _delta #used to check for dead or zombie audio streams in the pool. Disabling this line will remove the check if it becomes a performance issue.

#The main function used by your game to play audio.
func play(_audio_file:AudioFile = null) -> Node:
	var new_player:Node
	#Used for music to fade between old and new music.
	var fade :bool = false
	var out_music:Node
	var in_db:float = -10
	#If the audio file is set to unique, we immediatly return the ongoing audio stream if its playing
	if _audio_file.is_unique:
		var temp:Node = _get_currently_playing(_audio_file)
		if temp: return temp
	
	#Null validation on parameter
	if _audio_file != null:
		match _audio_file.stream_type:
			AudioFile.TYPE.TWO_D:
				new_player = SAudioStreamPlayer2D.new()
			AudioFile.TYPE.THREE_D:
				new_player = SAudioStreamPlayer3D.new()
			_:
				new_player = SAudioStreamPlayer.new()
		new_player.audio_file = _audio_file
		#if there is only 1 file in teh audio file, there is no random.
		new_player.set_stream(_audio_file.get_random_audio())
		#Set to the right bus
		if _audio_file.is_music:
			new_player.bus = "Music"
			if music != null: 
				out_music = music
				fade = true
				in_db = _audio_file.volume_db
			music = new_player
		else: new_player.bus = "SFX"
		#Set DB of new stream to that in the audio file
		new_player.volume_db = _audio_file.volume_db
		#Set pitch. if min and max are 1, it will not change the pitch.
		new_player.pitch_scale = _audio_file.get_random_pitch()
		if new_player.stream != null:
			audio_stage.add_child(new_player)
			audio_pool.append(new_player)
			#Connecting signal of stream exiting the tree to the freed audio function
			new_player.AudioExiting.connect(_freed_audio)
			#Set process based on is music or always play
			if _audio_file.is_music: new_player.process_mode = PROCESS_MODE_ALWAYS
			elif _audio_file.always_play: new_player.process_mode = PROCESS_MODE_ALWAYS
			#If the music needs to fade, we tween the volume db of the outgoing and the incoming
			if fade: 
				new_player.volume_db = MIN_DB
				_fade_music(out_music, new_player, in_db)
			new_player.play()
	return new_player

#Resets the buses to the default values in the AudioData resource (see const above)
func reset_volumes() -> void:
	_update_audio_volume("Master", DEFAULT.master_volume)
	_update_audio_volume("Music", DEFAULT.music_volume)
	_update_audio_volume("SFX", DEFAULT.sfx_volume)
	VolumesUpdated.emit()

#Function to set the bus volumes based on player changes and/or save data
func set_volumes(_master:float = 1.0, _music :float = 1.0, _sfx :float = 1.0) -> void:
	_update_audio_volume("Master", _master)
	_update_audio_volume("Music", _music)
	_update_audio_volume("SFX", _sfx)
	VolumesUpdated.emit()

func _fade_music(_out:Node, _in:Node, _max_db_of_in:float) -> void:
	var tween1:Tween = get_tree().create_tween()
	tween1.tween_property(_out, "volume_db", MIN_DB, 1.0)
	var tween2:Tween = get_tree().create_tween()
	tween2.tween_property(_in, "volume_db", _max_db_of_in, 1.0)
	await tween1.finished
	_out.exit_tree()

#If dead/zombie audio stream are present they are queue_freed
func _clear_audio_pool() -> void:
	var x :int = 0
	var to_clear :Array = []
	while x < audio_pool.size():
		if audio_pool[x] != null and !audio_pool[x].playing:
			to_clear.append(x)
		x += 1
	if !to_clear.is_empty():
		for i:int in to_clear:
			if i < audio_pool.size():
				var temp:SAudioStreamPlayer = audio_pool.pop_at(i)
				if temp != null:
					temp.queue_free.call_deferred()

func _update_audio_volume(bus_name :String = "Master", percent :float = 1.0) -> void:
	if percent > -0.1 and percent <= 1.0:
		var bus_index:int = AudioServer.get_bus_index(bus_name)
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(percent))

#Exiting tree audio found in the audio pool is freed
func _freed_audio(_audio:Node) -> void:
	var x :int = 0
	var found :bool = false
	while x < audio_pool.size():
		if _audio == audio_pool[x]:
			found = true
			break
		x += 1
	if found:
		var _temp:Node = audio_pool.pop_at(x)
		_temp.queue_free.call_deferred()

func _get_currently_playing(_audio_file:AudioFile = null) -> Node:
	for each:SAudioStreamPlayer in audio_pool:
		if each != null and each.audio_file == _audio_file and each.is_playing():
			return each
	return null
