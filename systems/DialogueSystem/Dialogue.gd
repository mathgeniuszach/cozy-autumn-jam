extends Control

const DATA_LOC = "res://data/dialogue/"
const FACES = "faces/"
const COLORS = "characters.json"

var conversation = ""
export var text_speed = 0.02
export var text_full_stop = 0.35
export var text_half_stop = 0.15
export var text_drag = 0.1

var dialogue
var phrase_num = 0
var phrase_finished = false
var playing = true
var active = false

onready var characters: Dictionary = _get_characters()

onready var timer = $DialogueBox/Timer
onready var nameUI = $DialogueBox/Name
onready var textUI = $DialogueBox/Text
onready var portrait = $DialogueBox/Portrait
onready var indicator = $DialogueBox/Indicator
onready var ticker = $Ticker

signal dialogue_end(conversation)
signal anim(anim_name)

func _process(_delta):
	$DialogueBox.visible = active
	indicator.visible = phrase_finished

func start(_conversation : String):
	end()
	conversation = _conversation
	
	phrase_num = 0
	phrase_finished = false
	playing = true
	active = true
	dialogue = _get_dialogue()
	assert(dialogue, "Dialogue not found")
	_next_phrase()

func end():
	phrase_finished = true
	playing = false
	active = false

func next():
	if playing:
		if phrase_finished:
			_next_phrase()
		else:
			textUI.visible_characters = len(textUI.text)

func pause(val : bool):
	playing = !val

func set_text_speed(val : float):
	text_speed = val
	timer.wait_time = text_speed

func _get_characters() -> Dictionary:
	var path = DATA_LOC + COLORS
	var file = File.new()
	assert(file.file_exists(path), "Characters file does not exist")
	
	file.open(path, file.READ)
	return parse_json(file.get_as_text())

func _get_dialogue() -> Array:
	var path = DATA_LOC + conversation + ".json"
	var file = File.new()
	assert(file.file_exists(path), 'File for conversation "' + conversation + '" does not exist')
	
	file.open(path, file.READ)
	return parse_json(file.get_as_text())

func _next_phrase():
	if phrase_num >= len(dialogue):
		phrase_finished = true
		if active: emit_signal("dialogue_end", conversation)
		active = false
		return
	
	phrase_finished = false
	textUI.visible_characters = 0
	
	var phrase = dialogue[phrase_num]
	var speaker = phrase["Name"]
	var character = characters.get(speaker, {})
	var talkspeed = character.get("Talkspeed", 1)
	var talkpitch = character.get("Talkpitch", 0.5)
	
	if phrase.has("Anims"):
		for anim in phrase["Anims"]:
			emit_signal("anim", anim)
	
	if phrase.has("Emotion"):
		var file = File.new()
		var img = DATA_LOC + FACES + speaker + phrase["Emotion"] + ".png"
		if file.file_exists(img):
			portrait.texture = load(img)
		else:
			portrait.texture = null
	else:
		portrait.texture = null
	
	if character.has("Color"):
		nameUI.bbcode_text = "[color=" + character["Color"] + "]" + speaker + "[/color]"
	else:
		nameUI.bbcode_text = speaker
	textUI.bbcode_text = phrase["Text"]
	
	var tick = 0
	
	while textUI.visible_characters < len(textUI.text):
		if textUI.visible_characters:
			match textUI.text[textUI.visible_characters-1]:
				'.':
					if textUI.text[textUI.visible_characters] == "." or (
						textUI.visible_characters-2 >= 0 and
						textUI.text[textUI.visible_characters-2] == "."
					):
						# If a neighbor is a period, drag instead of full stop
						timer.wait_time = text_drag / talkspeed
					else:
						timer.wait_time = (text_speed + text_full_stop) / talkspeed
				'!', '?':
					timer.wait_time = (text_speed + text_full_stop) / talkspeed
				',', ';':
					timer.wait_time = (text_speed + text_half_stop) / talkspeed
				_:
					timer.wait_time = text_speed / talkspeed
		else:
			timer.wait_time = text_speed / talkspeed
		
		timer.start()
		yield(timer, "timeout")
		
		if playing:
			if talkpitch > 0:
				tick += 1
				if tick >= 2:
					tick = 0
					ticker.pitch_scale = talkpitch + rand_range(-0.1, 0.1)
					if !ticker.playing: ticker.play()
			textUI.visible_characters += 1
	
	phrase_finished = true
	phrase_num += 1
