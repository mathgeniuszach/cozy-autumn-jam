extends Control

signal anim_done(anim)

func _anim_done(anim: String):
	emit_signal("anim_done", anim)
	if anim == "play":
		$Credits.visible = false

func animate(anim: String, time: float):
	$Animator.play(anim, -1, 1/time)

func _on_play_press():
	animate("play", 1.1)
	$Play.disabled = true
	$Play.focus_mode = Control.FOCUS_NONE
