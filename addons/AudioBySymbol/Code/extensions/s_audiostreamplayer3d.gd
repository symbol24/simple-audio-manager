class_name SAudioStreamPlayer3D extends AudioStreamPlayer3D

var audio_file:AudioFile

signal AudioExiting(audioStream:AudioStream)

func _ready() -> void:
	tree_exiting.connect(exit_tree)
	finished.connect(exit_tree)
	
func exit_tree() -> void:
	AudioExiting.emit(self)
