extends Spatial

signal game_finish

export var goal = 50
export var setback_time = 0.2

var press_timer = 0.0
var press_time = 0.0
var timer = 0.0
var playing = false
var progress = 0
var possible_keys = ["up", "down", "left", "right"]

export var max_anim_speed = 2.0
var anim_speed = 1

onready var anim = $Control/AnimationPlayer
onready var control = $Control

func _ready():
	anim.stop()

func start():
	anim.play()
	timer = 0.0
	progress = 0
	playing = true

func _process(delta):
	control.visible = playing
	if playing:
		if Input.is_action_just_pressed("cancel"):
			quit()
		if press_timer < 0.2:
			press_timer += delta
		else:
			press_time = 1
			press_timer = 0
		
		anim_speed = max_anim_speed * (1-press_time)
		anim.playback_speed = lerp(anim.playback_speed, clamp(anim_speed, 0.2, max_anim_speed), 0.3 )
		
		if timer <= 0:
			if progress > 0:
				progress -= 1
				timer = setback_time
		else:
			timer -= delta
		
		if progress >= goal:
			print("win")
			playing = false
			emit_signal("game_finish", true)
			anim.stop()

func quit():
	playing = false
	anim.stop()
	emit_signal("game_finish", false)

func _input(event):
	if playing:
		for n in possible_keys.size():
			if event.is_action_pressed(possible_keys[n]):
				progress += 1
				timer = setback_time
				press_time = press_timer
				press_timer = 0
