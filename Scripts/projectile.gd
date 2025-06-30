class_name projectile
extends RigidBody3D
@export_subgroup("Debug")
@export var debug_name: String
@export var debug_description: String
@export var debug_mode_enabled: bool = false
@export_subgroup("Movement")
@export var proj_starting_velocity: float
@export var proj_max_velocity: float
@export var proj_acceleration: float
@export var proj_max_distance: float = 1000.0
@export var proj_max_distance_enabled: bool = true
@export var proj_effected_by_gravity: bool = true
@export var custom_proj_grav: Vector3 = Vector3(0, -9.81, 0)
@export var velo_stays_constant: bool = false
@export_subgroup("Impact")
@export var does_damage: bool = true
@export var damage: float
@export var damage_type: String
@export var knockback_force: float

## The point from which the projectile starts moving, is recalculated upon being teleported
var starting_point: Vector3



func read_payload(payload: Dictionary):
	print("If this prints, this function was not overridden")
	return

func do_movement_check(delta: float):
	print("If this prints, this function was not overridden")
	return

func impact(body: Variant):
	print("If this prints, this function was not overridden")
	return

func delete_self():
	if debug_mode_enabled:
		print("Deleting projectile: " + debug_name)
	queue_free()
	
