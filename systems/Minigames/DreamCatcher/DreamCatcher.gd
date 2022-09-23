extends Control

var message = "Mash the given sequence of inputs."

#W->S->D->A->S->W

signal game_finish

export var fade_time = 0.5
export var wait_time = 0.5

export var goal = 40.0
func set_progress(p):
	progress = p
	texture.self_modulate.a = 0.8 * progress/goal + 0.2
var progress = 0.0 setget set_progress

var current_key = 0
var wait_timer = 0.0
var playing = false
var timer = 0.0
var target_transparency = 0.0
var new_key = false

var key_pattern = [0, 1, 2, 3, 1, 0]
var possible_keys = ["up", "down", "left", "right"]
var possible_key_symbols = ["^", "v", "<", ">"]

onready var text = $RichTextLabel
onready var texture = $TextureRect

func _ready():
	text.bbcode_text = ""
	texture.texture = preload("res://assets/textures/minigames/DreamCatcher.png")
	texture.self_modulate.a = 0.2

func start():
	playing = true
	new_key = true
	text.self_modulate.a = 0
	current_key = -1
	timer = 0.0
	wait_timer = 0.0
	progress = 0

func quit():
	playing = false
	text.self_modulate.a = 0
	emit_signal("game_finish", false)

func _process(delta):
	if playing:
		if Input.is_action_just_pressed("cancel"):
			quit()
		
		if progress >= goal:
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
		
		text.self_modulate.a = lerp(text.self_modulate.a, target_transparency, 0.2)

func _input(event):
	if playing:
		for n in possible_keys.size():
			if event.is_action_pressed(possible_keys[key_pattern[current_key]]): 
				if current_key < key_pattern.size()-1: current_key += 1
				else: current_key = 0
				new_key = true
				self.progress += 1

