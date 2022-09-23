extends Control

signal game_finish

enum States {STOPPED, DISPLAY, INPUT}
var _state = States.STOPPED

var possible_keys: Dictionary

export var item_alpha_start = 0.2

export var fade_in_time = 0.1
export var stay_time = 0.5
export var fade_out_time = 0.1

onready var prompt = $Prompt
onready var animator = $Animator
onready var item = $Item
onready var timer = $Timer

func _get_possible_keys():
	possible_keys = {
		"up": "^",
		"down": "v",
		"left": "<",
		"right": ">",
		"action": "o"
	}

func _get_item():
	pass

func _ready():
	prompt.text = ""
	prompt.self_modulate.a = 0
	item.texture = _get_item()
	item.self_modulate.a = item_alpha_start
	_get_possible_keys()

func start():
	pass

func _process(delta):
	if _state != States.STOPPED:
		if Input.is_action_just_pressed("cancel"):
			quit()

func quit():
	_state = States.STOPPED
	emit_signal("game_finish", false)

func _show_text(text: String):
	prompt.text = text
	animator.play("show_prompt", -1, 1/fade_in_time)
	yield(animator, "animation_finished")
	
	timer.start(stay_time)
	yield(timer, "timeout")
	
	animator.play("hide_prompt", -1, 1/fade_out_time)
	yield(animator, "animation_finished")
