extends Spatial

#W->S->D->A->S->W

signal game_finish

export var fade_time = 0.5
export var wait_time = 0.5

export var goal = 18.0
onready var _goal = 1 + goal * 6
var progress = 0

var current_key = 0
var wait_timer = 0.0
var playing = false
var timer = 0.0
var target_transparency = 0.0
var target_texture_transparency = 0.0
var new_key = false

var key_pattern = [0, 1, 2, 3, 1, 0]
var possible_keys = ["up", "down", "left", "right"]
var possible_key_symbols = ["W", "S", "A", "D"]

onready var text = $Control/VBoxContainer/RichTextLabel
onready var texture = $Control/VBoxContainer/TextureRect

func _ready():
	text.bbcode_text = ""

func start():
	playing = true
	new_key = true
	text.self_modulate.a = 0
	current_key = -1
	texture.self_modulate.a = 0
	timer = 0.0
	wait_timer = 0.0
	progress = 0

func quit():
	playing = false
	text.self_modulate.a = 0
	texture.self_modulate.a = 0
	emit_signal("game_finish", false)

func _process(delta):
	$Control.visible = playing
	if playing:
		if Input.is_action_just_pressed("cancel"):
			quit()
		
		if progress >= _goal:
			playing = false
			emit_signal("game_finish", true)
		
		if wait_timer > 0:
			wait_timer -= delta
		
		if wait_timer <= 0 && !new_key:
			text.bbcode_text = "[center]" + possible_key_symbols[key_pattern[current_key]] + "[/center]"
		
		if timer < fade_time && wait_timer <= 0:
			timer += delta
			target_transparency = timer/fade_time
		
		if new_key:
			target_transparency = 0
			wait_timer = wait_time
			timer = 0
			new_key = false
		
		target_texture_transparency = progress/_goal
		texture.self_modulate.a = lerp(texture.self_modulate.a, target_texture_transparency, 0.05)
		text.self_modulate.a = lerp(text.self_modulate.a, target_transparency, 0.2)

func _input(event):
	if playing:
		for n in possible_keys.size():
			if event.is_action_pressed(possible_keys[key_pattern[current_key]]): 
				if current_key < key_pattern.size()-1: current_key += 1
				else: current_key = 0
				new_key = true
				progress += 1

