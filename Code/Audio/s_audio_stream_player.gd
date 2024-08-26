class_name SAudioStreamPlayer extends AudioStreamPlayer

signal AudioExiting(audioStream)

func _ready() -> void:
	tree_exiting.connect(exit_tree)
	finished.connect(exit_tree)
	
func exit_tree() -> void:
	AudioExiting.emit(self)
