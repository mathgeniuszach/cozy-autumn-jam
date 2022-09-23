extends Spatial

onready var armature = $Armature
onready var skeleton = $Armature/Skeleton

const SQRT2 = sqrt(2)

func _process(delta):
	# Jank to the Jank
	translation.z = skeleton.get_bone_pose(0)[3].z/SQRT2
