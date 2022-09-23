extends "res://systems/Minigames/MagicMirror/MagicMirror.gd"

func _ready():
	._ready()
	message = "Remember the sequence and press the number keys."

func _get_possible_keys():
	possible_keys = {
		0: "0",
		1: "1",
		2: "2",
		3: "3",
		4: "4",
		5: "5",
		6: "6",
		7: "7",
		8: "8",
		9: "9"
	}

func _get_item():
	return preload("res://assets/textures/minigames/LuckyCharm.png")

func _is_valid_key(event):
	return (
		event is InputEventKey and event.pressed and (
			event.scancode >= KEY_0 and event.scancode <= KEY_9
		)
	)

func _get_pressed_key(event):
	return event.scancode - 48
