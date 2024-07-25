class_name SwimControl
extends Node3D
# Big thanks to Off-Grid Dev, https://youtu.be/DTEQwMtGh68?si=pzFLw16eLHB6r3sl

@onready var body:PlayerMovementController = get_parent()
@onready var depth_detector : RayCast3D = $DepthDetector
@onready var depth_check : Area3D = $DepthCheck
var depth : float = 0.0
var pocket_zone_override = false

func _ready():
	depth_detector.add_exception(depth_check)
func _process(delta):
	var bodies = depth_check.get_overlapping_areas()
	pocket_zone_override = false
	for body_volume:Area3D in bodies:
		if body_volume is SwimmableLiquid and pocket_zone_override == false:
			body.in_liquid = true
		if body_volume is PocketZone:
			body.in_liquid = false
			pocket_zone_override = true 
	depth = to_local(depth_detector.get_collision_point()).y
	#print(depth)
	if body.in_liquid and !depth_detector.is_colliding():
		depth = 2.0
	elif !body.in_liquid and !depth_detector.is_colliding():
		depth = 0.0

func get_depth():
	#print_debug(depth)
	return depth
