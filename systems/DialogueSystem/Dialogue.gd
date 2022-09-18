extends Control

const DATA_LOC = "res://data/dialogue/"

var conversation = ""
export var text_speed = 0.04
export var text_full_stop = 0.8
export var text_half_stop = 0.2

var dialogue
var phrase_num = 0
var phrase_finished = false
var playing = true
var active = false

onready var timer = $DialogueBox/Timer
onready var nameUI = $DialogueBox/Name
onready var textUI = $DialogueBox/Text
onready var portrait = $DialogueBox/Portrait
onready var indicator = $DialogueBox/Indicator

signal dialogue_end(conversation)

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

func _get_dialogue() -> Array:
	var path = DATA_LOC + conversation + ".json"
	var file = File.new()
	assert(file.file_exists(path), "File path does not exist")
	
	file.open(path, file.READ)
	var text = file.get_as_text()
	var output = parse_json(text)
	
	return output

func _next_phrase():
	if phrase_num >= len(dialogue):
		phrase_finished = true
		if active: emit_signal("dialogue_end", conversation)
		active = false
		return
	
	phrase_finished = false
	
	nameUI.bbcode_text = dialogue[phrase_num]["Name"]
	textUI.bbcode_text = dialogue[phrase_num]["Text"]
	
	textUI.visible_characters = 0
	
	if dialogue[phrase_num].has("Emotion"):
		var file = File.new()
		var img = DATA_LOC + dialogue[phrase_num]["Name"] + dialogue[phrase_num]["Emotion"] + ".png"
		if file.file_exists(img):
			portrait.texture = load(img)
		else:
			portrait.texture = null
	else:
		portrait.texture = null
	
	timer.wait_time = text_speed
	while textUI.visible_characters < len(textUI.text):
		if textUI.visible_characters:
			match textUI.text[textUI.visible_characters-1]:
				'.', ';':
					timer.wait_time = text_speed + text_full_stop
				',':
					timer.wait_time = text_speed + text_half_stop
				_:
					timer.wait_time = text_speed
		
		timer.start()
		yield(timer, "timeout")
		
		if playing:
			textUI.visible_characters += 1
			
			# Add dialogue sfx here
	
	phrase_finished = true
	phrase_num += 1
