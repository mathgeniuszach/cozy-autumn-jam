extends "res://systems/Minigames/Base.gd"

var message = "Mash down, right, up, left to mix"

export var goal = 30.0

var pk = ["down", "right", "up", "left"]
var key = 0

var reset_timer = 1
var speed_timer = 2

func set_progress(p):
	progress = p
	if progress < 0: progress = 0
	item.self_modulate.a = (1 - item_alpha_start) * progress/goal + item_alpha_start
var progress = 0.0 setget set_progress

func _get_item():
	return preload("res://assets/textures/minigames/DreamCatcher.png")

func _ready():
	animator.playback_speed = 1
	animator.play("jiggle_h")

func start():
	self._state = States.INPUT

func _process(delta):
	._process(delta)
	reset_timer -= delta / 0.333
	if reset_timer <= 0:
		reset_timer = 1
		if progress > 0: self.progress -= 1
	
	if speed_timer < 0.5:
		speed_timer += delta
		if speed_timer >= 0.5:
			animator.playback_speed = 1

func _input(event):
	for k in pk:
		if event.is_action_pressed(k): 
			if k == pk[key]:
				key = (key + 1) % pk.size()
				self.progress += 1
			else:
				self.progress += 0.5
			
			if progress >= goal:
				emit_signal("game_finish", true)
				animator.playback_speed = 0.5
			
			speed_timer = 0
			animator.playback_speed = 2.5
			return
