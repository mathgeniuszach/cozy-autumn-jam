extends Spatial

signal game_finish

export var goal = 30
export var setback_time = 0.5
export var shake_time = 0.5

var game_play = false
var target_transparency = 0.0
var progress = 0.0
var setback_timer = 0.0
var key = ""
var key_name = ""
var possible_keys = ["up", "down", "left", "right", "action"]
var key_symbol = ["W","S","A","D","-"]

onready var control = $Control
onready var texture = $Control/VBoxContainer/TextureRect
onready var text = $Control/VBoxContainer/RichTextLabel

func start():
	texture.self_modulate.a = 0
	randomize()
	var rand = randi()%5+1
	key = possible_keys[rand-1]
	key_name = key_symbol[rand-1]
	text.bbcode_text = "[center]" + key_name + "[/center]"
	game_play = true

func quit():
	text.bbcode_text = ""
	game_play = false
	emit_signal("game_finish", false)

func _process(delta):
	control.visible = game_play
	if game_play:
		if Input.is_action_just_pressed("cancel"):
			quit()
		
		texture.self_modulate.a = lerp(texture.self_modulate.a, target_transparency, 0.1)
		
		if setback_timer > 0:
			setback_timer -= delta
		
		if Input.is_action_just_pressed(key):
			progress += 1
			target_transparency = progress/goal
		elif setback_timer <= 0 && texture.self_modulate.a > 0:
			progress -= 1
			target_transparency = progress/goal
			setback_timer = setback_time
		
		if progress == goal:
			emit_signal("game_finish", true)
			text.bbcode_text = ""
			game_play = false
