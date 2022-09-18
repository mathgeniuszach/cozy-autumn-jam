extends Node2D

onready var dialogue = $Dialogue

func _ready():
	dialogue.start("text")

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		dialogue.next()
	
	if Input.is_action_just_pressed("ui_up"):
		dialogue.pause(false)
	
	if Input.is_action_just_pressed("ui_down"):
		dialogue.pause(true)
