extends Node


signal VolumesUpdated()
signal BusVolumeUpdate(bus:String, value:float)


const AUDIO_STAGE := preload("res://addons/AudioBySymbol/Scenes/Audio/audio_stage.tscn")
const DEFAULT := "res://Audio/default.tres"
const MIN_DB := -60.0
const MAX_DB := 0.0


var default:AudioData = null
var audio_stage:AudioStage
var audio_pool:Array = []
var music:SAudioStreamPlayer = null
var audio_check_timer :float = 0.0:
	set(_value):
		audio_check_timer = _value
		if audio_check_timer >= delay:
			audio_check_timer = 0.0
			_clear_audio_pool()
# Default value of delay is 60 seconds for the check of dead/zombie audio streams
var delay :float = 60.0


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	BusVolumeUpdate.connect(_update_audio_volume)
	add_to_group("SimpleAudioManager")

	# Creates the audio stage as a child of the autoload.
	audio_stage = AUDIO_STAGE.instantiate() as AudioStage
	add_child(audio_stage)

	# Create AudioData if not one present
	default = _create_audio_data()

	# Creates audio Bus for Music and SFX if they are not already present
	if AudioServer.get_bus_index("Music") != 1: 
		AudioServer.add_bus(1)
		AudioServer.set_bus_name(1, "Music")
	if AudioServer.get_bus_index("SFX") != 2: 
		AudioServer.add_bus(2)
		AudioServer.set_bus_name(2, "SFX")


func _process(_delta:float) -> void:
	# Used to check for dead or zombie audio streams in the pool. Disabling this line will remove the check if it becomes a performance issue.
	audio_check_timer += _delta 


# The  function used by your game to play non-2D and non-3D audio.
func play_audio(_audio_file:AudioFile = null) -> SAudioStreamPlayer:
	if _audio_file != null:
		# If the audio file is set to unique, we immediatly return the ongoing audio stream if its playing
		if _audio_file.is_unique:
			var temp:SAudioStreamPlayer = _get_currently_playing(_audio_file)
			if temp: return temp
			
		# Used for music to fade between old and new music.
		var fade :bool = false
		var out_music:SAudioStreamPlayer
		var in_db:float = -10
		
		var new_player:SAudioStreamPlayer = _get_audio_stream(_audio_file, 1) as SAudioStreamPlayer
		new_player.name = _audio_file.id
		
		# If music 
		if _audio_file.is_music:
			# If music already playing
			if music != null:
				print(music.name, " is playing")
				out_music = music
				fade = true
				in_db = _audio_file.volume_db

			music = new_player
		
			# Trigger music fade
			if fade: 
				music.volume_db = MIN_DB
				_fade_music(out_music, music, in_db)
			
		
		new_player.name = _audio_file.id

		if new_player: new_player.play()
			
		return new_player
	else:
		push_warning("Pay_Audio is receiving a null value.")
		return null


# The function used to play 2D audio
func play_audio_2d(_audio_file:AudioFile = null, _position:Vector2 = Vector2.ZERO) -> SAudioStreamPlayer2D:
	if _audio_file != null:
		if _audio_file.is_unique:
			var temp:Node = _get_currently_playing(_audio_file)
			if temp and temp is SAudioStreamPlayer2D: return temp as SAudioStreamPlayer2D
			
		var new_player:SAudioStreamPlayer2D = _get_audio_stream(_audio_file, 2) as SAudioStreamPlayer2D
		
		if new_player: 
			new_player.set_deferred("global_position", _position)
			new_player.play()
		return new_player
	else:
		push_warning("Pay_Audio_2D is receiving a null value.")
		return null
		

# The function used to play 3D audio
func play_audio_3d(_audio_file:AudioFile = null, _position:Vector3 = Vector3.ZERO) -> SAudioStreamPlayer3D:
	if _audio_file != null:
		if _audio_file.is_unique:
			var temp:Node = _get_currently_playing(_audio_file)
			if temp and temp is SAudioStreamPlayer3D: 
				return temp as SAudioStreamPlayer3D
			
		var new_player:SAudioStreamPlayer3D = _get_audio_stream(_audio_file, 3) as SAudioStreamPlayer3D
		
		if new_player: 
			new_player.set_deferred("global_position", _position)
			new_player.play()
		return new_player
	else:
		push_warning("Pay_Audio_3D is receiving a null value.")
		return null


# Resets the buses to the default values in the AudioData resource (see const above)
func reset_volumes() -> void:
	_update_audio_volume("Master", default.master_volume)
	_update_audio_volume("Music", default.music_volume)
	_update_audio_volume("SFX", default.sfx_volume)
	VolumesUpdated.emit()


# Function to set the bus volumes based on player changes and/or save data
func set_volumes(_master:float = 1.0, _music :float = 1.0, _sfx :float = 1.0) -> void:
	_update_audio_volume("Master", _master)
	_update_audio_volume("Music", _music)
	_update_audio_volume("SFX", _sfx)
	VolumesUpdated.emit()


func stop_music() -> void:
	if music != null and music.playing:
		music.stop()
		music = null


func _create_audio_data() -> AudioData:
	var result:AudioData = AudioData.new()
	var dir:DirAccess = DirAccess.open("res://")

	if not dir.dir_exists("Audio"):
		var error = dir.make_dir("Audio")
		if error != OK:
			push_error("Unable to create Audio folder. Error %s received." % error)

	if dir.dir_exists("Audio"):
		var error = FileAccess.file_exists(DEFAULT)
		if not error:
			error = ResourceSaver.save(result, DEFAULT)
			if error != OK:
				push_error("Unable to save new AudioData. Error: ", error)
		else:
			result = ResourceLoader.load(DEFAULT)
			if result != null:
				print("AudioData succesfully loaded.")
			
	else:
		push_error("Unable to save new AudioData as Audio folder cannot be accessed.")

	return result
	

func _get_audio_stream(_audio_file:AudioFile, _type:int = 1) -> Node:
	var new_player:Node
	
	# Set based on type (1 normal, 2 2D, 3 3D)
	match _type:
		2:
			new_player = SAudioStreamPlayer2D.new()
		3:
			new_player = SAudioStreamPlayer3D.new()
		_:
			new_player = SAudioStreamPlayer.new()
	
	# Null validation on parameter
	if _audio_file != null:
		# If there is only 1 file in teh audio file, there is no random.
		new_player.set_stream(_audio_file.get_random_audio())
		# Set to the right bus
		if _audio_file.is_music:
			new_player.bus = "Music"
		else: new_player.bus = "SFX"
		# Set DB of new stream to that in the audio file
		new_player.volume_db = _audio_file.volume_db
		# Set pitch. if min and max are 1, it will not change the pitch.
		new_player.pitch_scale = _audio_file.get_random_pitch()
		if new_player.stream != null:
			audio_stage.add_child(new_player)
			audio_pool.append(new_player)
			# Set the audio file inside the AudioStreamPlayer to the audio file received
			new_player.audio_file = _audio_file
			# Connecting signal of stream exiting the tree to the freed audio function
			new_player.AudioExiting.connect(_freed_audio)
			# Set process based on is music or always play
			if _audio_file.is_music: 
				new_player.process_mode = PROCESS_MODE_ALWAYS
			elif _audio_file.always_play: 
				new_player.process_mode = PROCESS_MODE_ALWAYS
			# If the music needs to fade, we tween the volume db of the outgoing and the incoming
	return new_player


func _fade_music(_out:SAudioStreamPlayer, _in:SAudioStreamPlayer, _max_db_of_in:float) -> void:
	var tween:Tween = audio_stage.create_tween()
	tween.tween_property(_out, "volume_db", MIN_DB, 1.0)
	tween.parallel()
	tween.tween_property(_in, "volume_db", _max_db_of_in, 1.0)
	tween.finished.connect(_out.exit_tree)


# If dead/zombie audio stream are present they are queue_freed
func _clear_audio_pool() -> void:
	var x :int = 0
	var to_clear :Array = []
	while x < audio_pool.size():
		if audio_pool[x] != null and !audio_pool[x].playing:
			to_clear.append(x)
		x += 1
	if not to_clear.is_empty():
		for i:int in to_clear:
			if i < audio_pool.size():
				var temp:Node = audio_pool.pop_at(i)
				if temp != null:
					temp.queue_free.call_deferred()


func _update_audio_volume(bus_name :String = "Master", percent :float = 1.0) -> void:
	if percent > -0.1 and percent <= 1.0:
		var bus_index:int = AudioServer.get_bus_index(bus_name)
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(percent))


# Exiting tree audio found in the audio pool is freed
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
	for each:Node in audio_pool:
		if each != null and each.audio_file == _audio_file and each.is_playing():
			return each
	return null
