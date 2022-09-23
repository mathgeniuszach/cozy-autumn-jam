extends Spatial

signal interact(object)

const move_map = {
	"up": Vector2(-1, 0),
	"down": Vector2(1, 0),
	"left": Vector2(0, -1),
	"right": Vector2(0, 1)
}

onready var Player = $Player
#onready var Customer = $Customer/Character
onready var CustomerMesh = $Customer/MeshInstance
onready var PlayerAnimator = $Player/Character/AnimationPlayer
onready var BigMesh = $BigMesh

export var speed = 3
export var angular_speed = 10
export var resistance = 500

var motion: Vector3 = Vector3.ZERO
var last_move_vec = Vector3(move_map["down"].y, 0, move_map["down"].x)
var last_move_angle = move_map["down"].angle()

var unlocked = false
var no_act_time = 0

# ARGB color
var customers = [
	{ # Mushroom witch
		"model": preload("res://assets/models/Characters/Mushroomwitch.OBJ"),
		"y": -4.468,
		"color": Color(0x7200276a)
	},
	{ # Dotting mother
		"model": preload("res://assets/models/Characters/mother.OBJ"),
		"y": -4.468,
		"color": Color(0x0072696c)
	},
	{ # Jack-o'-NightLight
		"model": preload("res://assets/models/Characters/pumpkin.OBJ"),
		"y": -4.468,
		"color": Color(0xa4630071)
	},
	null, # No customer
	{ # Vampire Prince
		"model": preload("res://assets/models/Characters/Vampire.OBJ"),
		"y": 0.863,
		"scale": Vector3(0.5, 0.5, 0.5),
		"color": Color(0xb20b006f)
	},
	{ # Mushroom witch again
		"model": preload("res://assets/models/Characters/Mushroomwitch.OBJ"),
		"y": -4.468,
		"color": Color(0x7200276a)
	}
]

func switch_customer(i):
	var c = customers[i]
	if c:
#		Customer.mesh.mesh = c["model"]
#		Customer.translation.y = c["y"]
#		Customer.mesh.get_active_material(0).albedo_color = c["color"]
#		Customer.animator.play("Reset")
		CustomerMesh.mesh = c["model"]
		CustomerMesh.translation.y = c["y"]
		CustomerMesh.scale = c.get("scale", Vector3(50, 50, 50))
		CustomerMesh.get_active_material(0).albedo_color = c["color"]

func _ready():
	PlayerAnimator.play("Armature|mixamocom|Layer0")

func reset_look_angle():
	last_move_vec = Vector3(move_map["down"].y, 0, move_map["down"].x)
	last_move_angle = move_map["down"].angle()
	PlayerAnimator.play("Reset")

func _process(delta):
	if unlocked:
		var move_vec: Vector2 = Vector2.ZERO
		for input in move_map:
			if Input.is_action_pressed(input):
				move_vec += move_map[input]
		move_vec = move_vec.normalized()
		
		if move_vec == Vector2.ZERO:
			PlayerAnimator.stop(false)
		else:
			PlayerAnimator.play("Armature|mixamocom|Layer0")
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
				var pt = Vector3(Player.translation.x, 1, Player.translation.z)
				var looking_at = get_world().direct_space_state.intersect_ray(pt, pt + last_move_vec*1.5, [Player, BigMesh])
				if looking_at and looking_at["collider"]:
					emit_signal("interact", looking_at["collider"].name)
