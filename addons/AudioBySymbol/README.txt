I developped Simple Audio Manager as a way to have access to a quick audio manager for game jams and then decided to release it as a plugin.

The plugin auto adds an Audio autoload.

All that is needed is to create AudioFile resources with your, well, audio files, and then use these AudioFile in your script with the Audio autoload.

Example: Audio.play_audio(my_audio_file)

The Simple Audio Manager will create the Music and SFX buses on runtime if they do not already exist.

Currently the manager supports only 1 music file being played at a time, and will fade between the old and the new music (if music is playing). 

The AudioFile resource can have multiple audio streams (files) set, and will randomly pick one on play.

AudioFile properties:
	- volume_db: decibel volume.
	- min and max pitch: if values other than 1 are used, will return a value between the min and max.
	- is_music: if true, will play on the Music Bus. Music also plays when the tree is paused. If false, will play on SFX bus.
	- always_play: if true, SFX is also played when the tree is paused. Ignored if is_music is true.
	- is_unique: if true, will not play if another AudioStreamPlayer with the same AudioFile is currently playing.

Note: audio file type has been removed and moved to functions in the audio autoload.

For any comments, questions, or suggestions, do not hesitate to contact me @ symbol24.info@gmail.com.

Thanks!
