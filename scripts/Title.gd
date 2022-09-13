extends Control

signal open_complete
signal enter_complete
signal end_complete

func _anim_done(anim: String):
	match anim:
		"open":
			emit_signal("open_complete")
		"enter":
			emit_signal("enter_complete")
		"end":
			emit_signal("end_complete")

func open(time: float):
	$Animator.play("open", 1, 1/time)

func enter(time: float):
	$Animator.play("enter", 1, 1/time)

func end(time: float):
	$Animator.play("end", 1, 1/time)

func _on_play_press():
	enter(1)
