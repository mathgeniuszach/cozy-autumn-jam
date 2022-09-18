extends Control

signal anim_done

onready var Dialoger = $"../../"

func _anim_done(anim: String):
	emit_signal("anim_done", anim)

func animate(anim: String, time: float):
	$Animator.play(anim, 1, 1/time)

func _on_play_press():
	animate("enter", 1)
