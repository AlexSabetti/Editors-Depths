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

func _process(_delta):
	var bodies = depth_check.get_overlapping_areas()
	pocket_zone_override = false
	var counter = 0
	for body_volume:Area3D in bodies:
		# if body_volume is SwimmableLiquid and pocket_zone_override == false:
		# 	body.in_liquid = true
		if body_volume.get_parent() is UniqueRegion:
			#print(body_volume.get_parent())
			if body_volume.get_parent().region_type == "Pocket":
				#print("Pocket detected, out of liquid")
				body.in_liquid = false
				pocket_zone_override = true
			else:
				#print("In liquid")
				body.in_liquid = true
				pocket_zone_override = false
			body.surrounded_by = null
		elif body_volume is PocketZone:
			body.surrounded_by = body_volume
			if body_volume.is_gas:
				print("Gas detected")
				body.in_liquid = false
				pocket_zone_override = true
			else:
				print("Liquid detected")
				body.in_liquid = true
				pocket_zone_override = false
		else:
			body.in_liquid = true
			pocket_zone_override = false
			body.surrounded_by = null
		counter += 1;
	print(counter, " bodies detected in depth check")
	if pocket_zone_override:
		depth = to_local(depth_detector.get_collision_point()).y
		if !depth_detector.is_colliding():
			depth = 0.0
	else: 
		depth = 2.0
		body.in_liquid = true
	
	#print(depth)
	# if body.in_liquid and !depth_detector.is_colliding():
	# 	depth = 2.0
	# elif !body.in_liquid and !depth_detector.is_colliding():
	# 	depth = 0.0

func get_depth():
	#print_debug(depth)
	return depth
	