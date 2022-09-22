extends Spatial

enum GameState {
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
onready var MainCamera = $World/MainCamera
onready var SideCamera = $World/SideCamera
onready var DoorbellPlayer = $DoorbellPlayer
onready var MusicPlayer = $MusicPlayer

var correct_creations = [
	"LuckyCharm",
	"VoodooDoll",
	"DreamCatcher",
#	"RecoveryPotion",
	"MagicMirror",
	"SleepPowder"
]
var minigames = _get_minigames()

var creating = false
var created = null
var level = 0

func set_state(v):
	if state != v:
		if state == GameState.Dialogue:
			World.unlocked = true
			World.no_act_time = 0.5
		state = v
		if state == GameState.Dialogue:
			World.unlocked = false
	time = 0
var state = GameState.Opening setget set_state
var time = 0

func _get_minigames():
	var ms = {}
	for minigame in correct_creations:
		ms[minigame] = load("res://systems/Minigames/%s/%s.tscn" % [minigame, minigame])
	return ms

func _process(delta):
	# If nothing else is focused and the user focuses, select the options button
	if Input.is_action_just_pressed("ui_focus_next") or Input.is_action_just_pressed("ui_focus_prev"):
		if not UI.get_focus_owner():
			OptionsButton.grab_focus()
	
	time += delta
	match state:
		GameState.Opening:
			if time >= 0.3:
				MusicPlayer.queue_song("calm")
				Title.animate("open", 3.5)
				yield(Title, "anim_done")
				self.state = GameState.Menu
		GameState.Dialogue:
			if Input.is_action_just_pressed("action"):
				Dialogue.next()

func _anim_done(anim: String):
	match anim:
		"play":
			# On play anim complete, pause for 0.3 seconds
			Timer.start(0.3)
			yield(Timer, "timeout")
			
			# Now display opening dialogue
			Player.visible = true
			$UI/Title/Fader.fade = 0
			Dialogue.start("opening")
			self.state = GameState.Dialogue
			yield(Dialogue, "dialogue_end")
			
			# Pause another 0.3 seconds
			Timer.start(0.3)
			yield(Timer, "timeout")
			
			# Now enter
			Title.animate("enter", 1.1)
			yield(Title, "anim_done")
			
			# Finally, enter moving state and let the player choose where to go
			self.state = GameState.Moving

func _interact(object: String):
	match object[0]:
		"w": # Interacted with a wall
			Dialogue.start("wall")
			self.state = GameState.Dialogue
			yield(Dialogue, "dialogue_end")
			self.state = GameState.Moving
		"c": # Interacted with the counter
			World.unlocked = false
			if creating:
				# Submission
				if created:
					# Fade out into response
					Title.animate("fade_out", 0.5)
					yield(Title, "anim_done")
					
					# Switch camera
					SideCamera.current = true
					
					# Fade back in
					Title.animate("fade_in", 0.5)
					yield(Title, "anim_done")
					
					# Check if submission was correct
					if created == correct_creations[level-1]:
						# Correct submission
						Dialogue.start("puzzle%d/correct" % level)
						creating = false
					else:
						# Incorrect submission
						Dialogue.start("puzzle%d/incorrect" % level)
					
					# "Delete" creation and await dialogue end
					created = null
					self.state = GameState.Dialogue
					yield(Dialogue, "dialogue_end")
					
					# Check if all levels have been completed
					if not creating and level >= len(correct_creations):
						# We beat everything! Transition to end screen.
						MusicPlayer.queue_song(null)
						Title.animate("end", 4)
						Timer.start("2")
						yield(Timer, "timeout")
						MusicPlayer.queue_song("calm")
						self.state = GameState.End
						return
					
					# Fade out
					MusicPlayer.queue_song(null)
					Title.animate("fade_out", 0.5)
					yield(Title, "anim_done")
					
					# Switch camera and determine what to do with the customer
					MainCamera.current = true
					if not creating:
						# Successful submission. Hide the customer, and play bell
						if level != 4:
							$World/Customer.visible = false
							DoorbellPlayer.play()
							yield(DoorbellPlayer, "finished")
					# Fade back in
					MusicPlayer.queue_song("calm")
					Title.animate("fade_in", 0.5)
					yield(Title, "anim_done")
					
					# Return control
					self.state = GameState.Moving
				else:
					# Nothing made, so just show dialogue and continue
					Dialogue.start("nothing_made")
					self.state = GameState.Dialogue
					yield(Dialogue, "dialogue_end")
					self.state = GameState.Moving
			else:
				# Fade out into next level
				MusicPlayer.queue_song(null)
				Title.animate("fade_out", 0.5)
				yield(Title, "anim_done")
				
				# increment level
				level += 1
				# Switch camera, add customer model, and bell
				SideCamera.current = true
				if level != 4:
					DoorbellPlayer.play()
					yield(DoorbellPlayer, "finished")
					$World/Customer.visible = true
				
				# Fade back in, now with character in place
				MusicPlayer.queue_song("spicy_intro")
				Title.animate("fade_in", 0.5)
				yield(Title, "anim_done")
				
				# New customer prompt
				Dialogue.start("puzzle%d/prompt" % level)
				self.state = GameState.Dialogue
				yield(Dialogue, "dialogue_end")
				
				# Fade back out
				Title.animate("fade_out", 0.5)
				yield(Title, "anim_done")
				
				# Switch camera again
				MainCamera.current = true
				
				# Fade back in
				Title.animate("fade_in", 0.5)
				yield(Title, "anim_done")
				
				# Return control in "creating" mode
				creating = true
				self.state = GameState.Moving
				
		"b": # Interacted with the wrong side of the counter
			Dialogue.start("flip_counter")
			self.state = GameState.Dialogue
		"m": # Interacted with a minigame starter
			# If not making stuff, print specific dialog related to that thing
			if not creating:
				Dialogue.start("minigames/%s_nocraft" % object.substr(1))
				self.state = GameState.Dialogue
				yield(Dialogue, "dialogue_end")
				self.state = GameState.Moving
				return
			
			# If something was already made, don't make another thing
			if created:
				Dialogue.start("already_made")
				self.state = GameState.Dialogue
				yield(Dialogue, "dialogue_end")
				self.state = GameState.Moving
				return
			
			World.unlocked = false
			
			# Fade out
			Title.animate("fade_out", 0.5)
			yield(Title, "anim_done")
			
			# Get minigame
			created = object.substr(1)
			var minigame = minigames[created].instance()
			add_child(minigame)

			# Switch camera and move player model
			var ptransform = Player.transform
			# TODO: NEW CAMERA AND PLAYER LOCATION

			# Fade in
			Title.animate("fade_in", 0.5)
			yield(Title, "anim_done")

			# Transfer control to minigame
			self.state = GameState.Minigame
			minigame.start()
			var success = yield(minigame, "game_finish")
			if not success: created = null

			# Fade out
			Title.animate("fade_out", 0.5)
			yield(Title, "anim_done")

			# Switch camera and player model back
			minigame.queue_free()
			MainCamera.current = true
			Player.transform = ptransform

			# Fade back in
			Title.animate("fade_in", 0.5)
			yield(Title, "anim_done")
			
			# Dialogue
			if success:
				Dialogue.start("finish_minigame")
				self.state = GameState.Dialogue
				yield(Dialogue, "dialogue_end")
			
			# Return control
			self.state = GameState.Moving

func _on_anim_request(anim_name):
	match anim_name:
		"fade_in":
			Title.animate("fade_in", 0.5)
		"fade_out":
			Title.animate("fade_out", 0.5)

func _minigame_complete():
	pass
