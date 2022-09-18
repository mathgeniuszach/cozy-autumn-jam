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

func set_state(v):
	state = v
	time = 0
var state = GameState.Wait setget set_state
var time = 0

onready var Title = $UI/Title
onready var OptionsButton = $UI/Options/Button
onready var Dialogue = $UI/Dialogue

func _process(delta):
	# If nothing else is focused and the user focuses, select the options button
	if Input.is_action_just_pressed("ui_focus_next") or Input.is_action_just_pressed("ui_focus_prev"):
		if not $UI.get_focus_owner():
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
			self.state = GameState.Dialogue
			Dialogue.start("opening")
