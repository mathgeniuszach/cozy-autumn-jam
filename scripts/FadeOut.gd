extends ColorRect

func set_fade(v):
	fade = v
	visible = v < 1
	
	var center = get_viewport_rect().size / 2
	material.set("shader_param/center", center)
	material.set("shader_param/radius_squared", center.length_squared() * fade * fade)

export var fade: float = 0 setget set_fade

func _ready():
	material.set("shader_param/color", Vector3(color.r, color.g, color.b))
