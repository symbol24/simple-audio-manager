@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("Audio", "res://addons/AudioBySymbol/Code/Autoloads/audio.gd")

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
