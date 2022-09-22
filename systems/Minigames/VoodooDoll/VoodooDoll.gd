extends "res://systems/Minigames/Base.gd"

var message = "Mash the given key. \"o\" is action."

export var goal = 30.0
export var setback_time = 0.5
export var shake_time = 0.5

func set_progress(p):
	progress = p
	item.self_modulate.a = (1 - item_alpha_start) * progress/goal + item_alpha_start
var progress = 0.0 setget set_progress

var setback_timer = 0.0
var key = ""
var key_name = ""

func start():
	var pkeys = possible_keys.keys()
	key = pkeys[randi() % pkeys.size()]
	
	animator.play("show_prompt", -1, 1/fade_in_time)
	prompt.text = possible_keys[key]
	_state = States.INPUT

func _process(delta):
	._process(delta)
	
	if _state == States.INPUT:
		if setback_timer > 0:
			setback_timer -= delta
		
		if Input.is_action_just_pressed(key):
			self.progress += 1.0
			if progress >= goal:
				emit_signal("game_finish", true)
		elif setback_timer <= 0 && progress > 0:
			self.progress -= 1.0
			setback_timer = setback_time
		
