extends Spatial

enum GameState {
	Wait,
	Opening,
	Menu,
	Moving,
	Dialog,
	Minigame,
	End
}

func set_state(v):
	state = v
	time = 0
var state = GameState.Wait setget set_state
var time = 0

onready var Title = $UI/Title
onready var Dialogue = $UI/Dialogue

func _process(delta):
	time += delta
	match state:
		GameState.Wait:
			if time >= 0.3:
				self.state = GameState.Opening
				Title.animate("open", 3.5)

