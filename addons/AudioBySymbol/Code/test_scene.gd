class_name TestScene 
extends Control

const DEFAULT = preload("res://addons/AudioBySymbol/Data/Audio/default.tres")
const TEST_MUSIC = preload("res://addons/AudioBySymbol/Data/Audio/test_music.tres")
const TEST_SOUND = preload("res://addons/AudioBySymbol/Data/Audio/test_sound.tres")
const TEST_SOUND_2D = preload("res://addons/AudioBySymbol/Data/Audio/test_sound_2d.tres")
const TEST_SOUND_3D = preload("res://addons/AudioBySymbol/Data/Audio/test_sound_3d.tres")

@onready var btn_music: Button = %btn_music
@onready var btn_sfx: Button = %btn_sfx
@onready var btn_sfx_2d: Button = %btn_sfx2D
@onready var btn_sfx_3d: Button = %btn_sfx3D
@onready var btn_reset: Button = %btn_reset
@onready var slider_master: HSlider = %slider_master
@onready var slider_music: HSlider = %slider_music
@onready var slider_sfx: HSlider = %slider_sfx
@onready var lbl_master: Label = %lbl_master
@onready var lbl_music: Label = %lbl_music
@onready var lbl_sfx: Label = %lbl_sfx

var music:Node
var sfx:Node
var master_volume :float = 1.0
var music_volume :float = 1.0
var sfx_volume :float = 1.0
var delay :float = 0.3
var timer :float = 0.0:
	set(_value):
		timer = _value
		if timer >= delay:
			timer = 0.0
			Audio.set_volumes(master_volume, music_volume, sfx_volume)

func _ready() -> void:
	btn_music.pressed.connect(_music_pressed)
	btn_sfx.pressed.connect(_sfx_pressed)
	btn_sfx_2d.pressed.connect(_sfx2d_pressed)
	btn_sfx_3d.pressed.connect(_sfx3d_pressed)
	btn_reset.pressed.connect(_reset_pressed)
	slider_master.drag_ended.connect(_master_update)
	slider_music.drag_ended.connect(_music_update)
	slider_sfx.drag_ended.connect(_sfx_update)
	master_volume = DEFAULT.master_volume
	music_volume = DEFAULT.music_volume
	sfx_volume = DEFAULT.sfx_volume
	slider_master.value = master_volume
	slider_music.value = music_volume
	slider_sfx.value = sfx_volume
	Audio.reset_volumes()

func _music_pressed() -> void:
	if music == null:
		music = Audio.play(TEST_MUSIC)
	else:
		music.stop()
		music.exit_tree()

func _sfx_pressed() -> void:
	if sfx == null:
		sfx = Audio.play(TEST_SOUND)
		
func _sfx2d_pressed() -> void:
	if sfx == null:
		sfx = Audio.play(TEST_SOUND_2D)
		
func _sfx3d_pressed() -> void:
	if sfx == null:
		sfx = Audio.play(TEST_SOUND_3D)
		print("---------")
		print("3D audio requires a proper 3D environement. Only normal and 2D sounds are heard in this demo scene.")
		print("The 3D audio file was instantiated under name ", sfx.name)

func _reset_pressed() -> void:
	Audio.reset_volumes()
	master_volume = DEFAULT.master_volume
	music_volume = DEFAULT.music_volume
	sfx_volume = DEFAULT.sfx_volume

func _master_update(_value_changed:bool) -> void:
	if _value_changed:
		master_volume = slider_master.value
		Audio.set_volumes(master_volume, music_volume, sfx_volume)

func _music_update(_value_changed:bool) -> void:
	if _value_changed:
		music_volume = slider_music.value
		Audio.set_volumes(master_volume, music_volume, sfx_volume)

func _sfx_update(_value_changed:bool) -> void:
	if _value_changed:
		sfx_volume = slider_sfx.value
		Audio.set_volumes(master_volume, music_volume, sfx_volume)
