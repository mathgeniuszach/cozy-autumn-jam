extends Spatial

enum GameState {
	Wait,
	Fading,
	Menu,
	Game,
	End
}

func set_state(v):
	state = v
	time = 0
var state = GameState.Wait setget set_state
var time = 0

onready var Title = $UI/Title

func _process(delta):
	time += delta
	match state:
		GameState.Wait:
			if time >= 0.3:
				self.state = GameState.Fading
				Title.open(3.5)
		GameState.Game:
			if time >= 2:
				self.state = GameState.End
				Title.end(3)

func _on_open_complete():
	self.state = GameState.Menu

func _on_enter_complete():
	# Start Game
	self.state = GameState.Game
