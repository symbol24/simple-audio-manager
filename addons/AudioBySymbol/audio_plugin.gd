@tool
extends EditorPlugin

var dock:Control

func _enter_tree() -> void:
	add_autoload_singleton("Audio", "res://addons/AudioBySymbol/Code/Autoloads/audio_autoload.gd")

func _exit_tree() -> void:
	remove_autoload_singleton("Audio")
