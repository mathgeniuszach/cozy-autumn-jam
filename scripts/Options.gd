extends Control

export var BASE_COLOR = Color("#ffffe1")
export var LIGHT_COLOR = Color("#aed19a")
export var DARK_COLOR = Color("#7e9770")

onready var MusicVolume = $Panel/Rows/Music/MusicVolume
onready var MusicPercent = $Panel/Rows/Music/MusicPercent
onready var FXVolume = $Panel/Rows/FX/FXVolume
onready var FXPercent = $Panel/Rows/FX/FXPercent

var open = false
var opacity = 0
var mouse_in = true
var music_volume = 50
var fx_volume = 50

func _ready():
	$Panel.visible = false
	$Button.modulate = BASE_COLOR
	MusicVolume.focus_mode = Control.FOCUS_NONE
	FXVolume.focus_mode = Control.FOCUS_NONE
	load_opts()

func _on_btn_mouse_enter():
	$Button.modulate = LIGHT_COLOR

func _on_btn_mouse_exit():
	$Button.modulate = BASE_COLOR

func _on_btn_down():
	$Button.modulate = DARK_COLOR

func _on_btn_up():
	$Button.modulate = LIGHT_COLOR
	
	open = !open
	if open:
		$Panel.visible = true
		MusicVolume.focus_mode = Control.FOCUS_ALL
		FXVolume.focus_mode = Control.FOCUS_ALL
	else:
		MusicVolume.focus_mode = Control.FOCUS_NONE
		FXVolume.focus_mode = Control.FOCUS_NONE

func save_opts():
	var f = File.new()
	f.open("user://opts.save", File.WRITE)
	f.store_line(to_json({"music_volume": music_volume, "fx_volume": fx_volume}))

func load_opts():
	var f = File.new()
	if f.file_exists("user://opts.save"):
		f.open("user://opts.save", File.READ)
		var opts = parse_json(f.get_line())
		music_volume = opts["music_volume"]
		fx_volume = opts["fx_volume"]
	else:
		music_volume = 50
		fx_volume = 50
	
	MusicVolume.value = music_volume
	MusicPercent.text = str(music_volume)+"%"
	FXVolume.value = fx_volume
	FXPercent.text = str(fx_volume)+"%"

func _on_music_volume_change(value):
	music_volume = value
	MusicPercent.text = str(music_volume)+"%"

func _on_fx_volume_change(value):
	fx_volume = value
	FXPercent.text = str(fx_volume)+"%"

func _on_drag_end(_v):
	save_opts()

func _process(delta):
	if open:
		if opacity < 1:
			opacity += delta * 10
			if opacity > 1: opacity = 1
			$Panel.modulate.a = opacity
	else:
		if opacity > 0:
			opacity -= delta * 10
			if opacity < 0: opacity = 0
			$Panel.modulate.a = opacity
