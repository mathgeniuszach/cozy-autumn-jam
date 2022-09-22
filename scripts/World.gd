extends Spatial

signal interact(object)

const move_map = {
	"up": Vector2(-1, 0),
	"down": Vector2(1, 0),
	"left": Vector2(0, -1),
	"right": Vector2(0, 1)
}

onready var Player = $Player

export var speed = 3
export var angular_speed = 10
export var resistance = 500

var motion: Vector3 = Vector3.ZERO
var last_move_vec = Vector3(move_map["down"].y, 0, move_map["down"].x)
var last_move_angle = move_map["down"].angle()

var unlocked = false
var no_act_time = 0

func _process(delta):
	if unlocked:
		var move_vec: Vector2 = Vector2.ZERO
		for input in move_map:
			if Input.is_action_pressed(input):
				move_vec += move_map[input]
		move_vec = move_vec.normalized()
		
		if move_vec != Vector2.ZERO:
			last_move_vec = Vector3(move_vec.y, 0, move_vec.x)
			last_move_angle = move_vec.angle()
		
		var look = fmod(last_move_angle - Player.rotation.y + TAU, TAU) - PI
		if look:
			Player.rotate_y(sign(look)*min(abs(look), angular_speed*delta))
		if abs(look) < 1 and move_vec != Vector2.ZERO:
			Player.move_and_slide(last_move_vec*speed*(1-look))
		
		if no_act_time:
			no_act_time -= delta
			if no_act_time < 0: no_act_time = 0
		else:
			if Input.is_action_just_pressed("action"):
				var looking_at = get_world().direct_space_state.intersect_ray(Player.translation, Player.translation + last_move_vec, [Player])
				if looking_at and looking_at["collider"]:
					emit_signal("interact", looking_at["collider"].name)
