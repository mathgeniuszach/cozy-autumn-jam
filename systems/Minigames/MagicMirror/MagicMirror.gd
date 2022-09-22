extends Spatial

signal game_finish

enum States {STOPPED, DISPLAY, INPUT}
var _state = States.STOPPED

var key_pattern = []
var input_key_list = []

var possible_keys = ["up", "down", "left", "right", "action"]
var possible_key_symbols = ["^", "v", "<", ">", "o"]

export var total_keys = 4
var current_key = -1
var new_key = false

export var display_time = 0.0
export var delay_time = 0.0
export var fade_time = 0.0
onready var total_time = display_time + delay_time + fade_time * 2
var timer = 0

var target_transparency = 0

onready var text = $Control/RichTextLabel

func _ready():
	text.self_modulate.a = 0

func start():
	current_key = -1
	timer = total_time/2
	text.bbcode_text = ""
	_state = States.DISPLAY
	text.self_modulate.a = 0
	_new_set()

func _process(delta):
	if _state == States.DISPLAY:
		if Input.is_action_just_pressed("cancel"):
			quit()
		_show_key(delta)
	elif _state == States.INPUT:
		if Input.is_action_just_pressed("cancel"):
			quit()
		_input_keys(delta)

	text.self_modulate.a = lerp(text.self_modulate.a, target_transparency, 0.2)

func _show_key(delta : float):
	if timer < total_time:
		timer += delta
		if timer < total_time - fade_time:
			#fade in
			target_transparency = clamp(timer/fade_time, 0, 1)
		if timer < total_time - delay_time && timer > display_time + fade_time:
			#fade out
			target_transparency = 1-clamp(timer-(display_time+fade_time)/fade_time, 0, 1)
	else:
		if current_key < total_keys-1:
			#display next key
			timer = 0
			current_key += 1
			text.bbcode_text = "[center]" + possible_key_symbols[key_pattern[current_key]] + "[/center]"
			text.self_modulate.a = 0
		else:
			#end display keys
			_state = States.INPUT
			timer = 0
			current_key = 0

func _input_keys(delta : float):
	if current_key >= total_keys && !new_key:
		print(input_key_list)
		print(key_pattern)
		if input_key_list == key_pattern:
			print("win!")
			emit_signal("game_finish", true)
			_state = States.STOPPED
		else:
			start()
			_state = States.DISPLAY
			timer = 0
			current_key = -1
	else:
		if new_key:
			if timer < fade_time:
				timer += delta
				target_transparency = clamp(timer/fade_time, 0, 1)
			elif timer >= 0.3:
				timer = 0.0
				target_transparency = 0
				new_key = false

func _input(event):
	_handle_input(event)

func _handle_input(event):
	if _state == States.INPUT && current_key < total_keys:
		for n in possible_keys.size():
			if event.is_action_pressed(possible_keys[n]):
				print(possible_keys[n])
				input_key_list.push_back(n)
				text.bbcode_text = "[center]" + possible_key_symbols[key_pattern[current_key]] + "[/center]"
				current_key += 1
				timer = 0.0
				target_transparency = 0
				new_key = true

func _new_set():
	key_pattern.clear()
	input_key_list.clear()
	randomize()
	for n in total_keys:
		var rand = (randi()%possible_keys.size()+1)-1
		key_pattern.push_back(rand)
		print(possible_keys[rand])

func quit():
	_state = States.STOPPED
	text.self_modulate.a = 0
	emit_signal("game_finish", false)
