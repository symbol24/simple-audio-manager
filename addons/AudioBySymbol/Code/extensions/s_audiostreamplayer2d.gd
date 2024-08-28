class_name SAudioStreamPlayer2D 
extends AudioStreamPlayer2D

signal AudioExiting(audioStream:Node)

var audio_file:AudioFile

func _ready() -> void:
	tree_exiting.connect(exit_tree)
	finished.connect(exit_tree)
	
func exit_tree() -> void:
	AudioExiting.emit(self)
