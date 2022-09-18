extends Spatial

enum GameState {
	Wait,
	Opening,
	Menu,
	Moving,
	Dialogue,
	Minigame,
	End
}

onready var Title = $UI/Title
onready var OptionsButton = $UI/Options/Button
onready var Dialogue = $UI/Dialogue
onready var UI = $UI
onready var Timer = $Timer
onready var World = $World
onready var Player = $World/Player

var creating = false
var created = null
var level = 1

func set_state(v):
	if state != v:
		if state == GameState.Dialogue:
			World.unlocked = true
			World.no_act_time = 0.5
		state = v
		if state == GameState.Dialogue:
			World.unlocked = false
	time = 0
var state = GameState.Wait setget set_state
var time = 0

func _process(delta):
	# If nothing else is focused and the user focuses, select the options button
	if Input.is_action_just_pressed("ui_focus_next") or Input.is_action_just_pressed("ui_focus_prev"):
		if not UI.get_focus_owner():
			OptionsButton.grab_focus()
	
	time += delta
	match state:
		GameState.Wait:
			if time >= 0.3:
				self.state = GameState.Opening
				Title.animate("open", 3.5)
		GameState.Dialogue:
			if Input.is_action_just_pressed("action"):
				Dialogue.next()

func _anim_done(anim: String):
	match anim:
		"play":
			Timer.start(0.3)
			yield(Timer, "timeout")
			Player.visible = true
			Dialogue.start("opening")
			self.state = GameState.Dialogue
		"enter":
			self.state = GameState.Moving

func _dialogue_done(conversation: String):
	match conversation:
		"opening":
			Timer.start(0.3)
			yield(Timer, "timeout")
			Title.animate("enter", 1.1)
		_:
			self.state = GameState.Moving

func _interact(object: String):
	if object[0] == "w":
		Dialogue.start("wall")
		self.state = GameState.Dialogue
