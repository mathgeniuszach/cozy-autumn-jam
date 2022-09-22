extends "res://systems/Minigames/Base.gd"

var message = "Remember the directions and press the keys"

signal show_pattern

var key_pattern = []

export var total_keys = 4
var current_key = 0
var new_key = false

func _ready():
	._ready()
	current_key = 0

func start():
	_state = States.DISPLAY
	_new_set()
	emit_signal("show_pattern")

func _is_valid_key(event):
	for k in possible_keys.keys():
		if event.is_action_pressed(k):
			return true
	
	return false

func _get_pressed_key(event):
	for k in possible_keys.keys():
		if event.is_action_pressed(k):
			return k

func _input(event: InputEvent):
	if not animator.is_playing() and _state == States.INPUT and _is_valid_key(event):
		var key = _get_pressed_key(event)
		if key == key_pattern[current_key]:
			# Correct key
			item.self_modulate.a += (1 - item_alpha_start)/total_keys
			current_key += 1
			yield(_show_text(possible_keys[key]), "completed")
			if current_key >= total_keys:
				# Minigame done
				emit_signal("game_finish", true)
		else:
			# Incorrect key
			_state = States.DISPLAY
			yield(_show_text("Oops!"), "completed")
			current_key = 0
			item.self_modulate.a = item_alpha_start
			
			emit_signal("show_pattern")

func _new_set():
	key_pattern.clear()
	var pkeys = possible_keys.keys()
	for n in total_keys:
		var action = pkeys[randi()%pkeys.size()]
		key_pattern.push_back(action)

func _show_pattern():
	for key in key_pattern:
		yield(_show_text(possible_keys[key]), "completed")
	_state = States.INPUT
	current_key = 0
