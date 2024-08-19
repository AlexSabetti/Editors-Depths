class_name KineticRifle
extends Item

@export_category("Weapon Stats")
@export var firing_spd:float
@export var int_dmg: float
@export var change_state_time: float
@export var reload_time: float

@export_category("Ammo Specifics")
@export_enum("Hook", "Standard", "Gel", "Bouncing", "Incin") var ammo_type:int

@export_category("Weapon Specifics")
@export_enum("Grapple", "Pinpoint", "Scatter") var config_type: int
@export var pinpoint_max_ammo: int = 8
@export var scatter_max_ammo: int = 5

var max_ammo:int
var current_ammo:int

var barrel_tip:Node3D
var model_node:Node3D
var anim_handler:AnimationPlayer


var held_model:PackedScene

func _init(config:int, ammo_count:int, ammo_spec:int):
	#Item id should be 1
	item_id = 1

	config_type = config

	if ammo_spec != 0 and config == 0:
		ammo_type = 0 #Fix the conflict
	elif config != 0 and ammo_spec == 0:
		ammo_type = 1
	else:
		ammo_type = ammo_spec

	#Make sure the item version has the ground version's ammo	
	current_ammo = ammo_count

	if config_type == 0:
		#Grapple should only allow one ammo
		max_ammo = 1
	elif config_type == 1:
		#Pinpoint (Or long range rifle) config should max out at a pre-set ammo count
		max_ammo = pinpoint_max_ammo
	elif config_type == 2:
		#Scatter (Shotgun) config maxes out at pre-set ammo count
		max_ammo = scatter_max_ammo
	else:
		#May add more in future, for now default to 1
		max_ammo = 1
	
	if current_ammo > max_ammo:
			current_ammo = max_ammo
	
	hover_name = "Kinetic-Rifle | Config:{0}".format([config_type])
	scene_link = "res://Scenes/KineticRifle.tscn"

var hooked = false
var hook_anchor_pos:Vector3
var max_length:float
var gravity_affected_hook:bool = false
var firing:bool = false
var reach_range:float
var reloading:bool = false
var remaining_rope_length:float

##Primary Fire Function
func use(interactor: CharacterBody3D):
	var player:PlayerMovementController = interactor
	if hooked:
		print("Pulling here")
	else:
		if current_ammo <= 0 and reloading:
				return
		elif current_ammo <= 0 and !reloading:
			reloading = true
			
		else:
			anim_handler.stop()
			reloading = false
			current_ammo -= 1

		if config_type == 0 and hooked:
			#We'll start pulling the player in the direction of the hook
			print("testA")
		if config_type == 0 and !hooked and !firing:
			firing = true
			if gravity_affected_hook:
				print("testB")
			else:
				#No gravity, no drop-off, use raycast
				var space_state = get_world_3d().direct_space_state
				var initial_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(barrel_tip.global_position, barrel_tip.global_position + interactor.basis.z.normalized() * reach_range)
				#initial_query.collision_mask = 8
				var result = space_state.intersect_ray(initial_query)
				if result['collider'] != null:   
					firing = false
					hook_anchor_pos = result['position']
					var rope_vec:Vector3 = hook_anchor_pos - barrel_tip.global_position
					max_length = rope_vec.length()
					remaining_rope_length = max_length
		

func take_out(interactor:CharacterBody3D):
	anim_handler = held_model.get_local_scene().get_node("AnimHandler")

func reload():
	if current_ammo >= max_ammo:
		return

	print("Play reload anim here")
	reload_corroutine()

func reload_corroutine():
	await get_tree().create_timer(reload_time).timeout
	if !reloading:
		return
	else:
		current_ammo = max_ammo
		reloading = false