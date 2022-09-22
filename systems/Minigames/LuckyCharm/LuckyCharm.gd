extends "res://systems/Minigames/MagicMirror/MagicMirror.gd"

func _ready():
	possible_keys = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
	possible_key_symbols = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

func _handle_input(event):
	if _state == States.INPUT && current_key < total_keys:
		if event is InputEventKey and event.pressed:
			for n in 10:
				if event.scancode == 48 + n || event.scancode == 16777350 + n:
					input_key_list.push_back(n)
					text.bbcode_text = "[center]" + String(n) + "[/center]"
					current_key += 1
					timer = 0.0
					target_transparency = 0
					new_key = true
