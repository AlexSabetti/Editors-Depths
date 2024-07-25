class_name Portal
extends Interactable
@export_group("Linking")
@export var linked_portal: Portal
@export var unique_portal_id:int
@export var set_id:int
#@export var other_side_view: SubViewport

@export_group("Location Configs")
@export var exit_offset: Vector3;


@export_group("Interaction Configs")
@export var closes_upon_use: bool = false
@export var cinematic_portal: bool = false
@export var instant_teleportation: bool = true
@export var reacts_to_proximity: bool = false
#@export var shows_other_side: bool = true
@export var must_be_interacted_with: bool = false

@export_group("Interaction Labels")
@export var instructions: String = "Enter"

@export_group("Attachments")
#@export var portal_view: Camera3D
@export var portal_area: Area3D
@export var interact_area: Area3D
signal trigger_portal_anim()

@onready var visible_mesh:MeshInstance3D = get_node("Area3d/PortalMesh")

var signal_manager = VoidScreamers
var disabled: bool = false
var dormant: bool = true
var open: bool = true

func _ready():
	if reacts_to_proximity:
		open = false
	#if shows_other_side:
		#other_side_view = linked_portal.other_side_view
		#portal_view.global_transform = global_transform
	signal_manager.connect("teleporter_used", receiveTeleportRequest)
	

func approached_zone(body):
	if !disabled && !dormant:
		if reacts_to_proximity:
			if must_be_interacted_with && body is PlayerController:
				#Play opening animation and idle animation
				open = true
			elif must_be_interacted_with && body != PlayerController:
				# Gotta check if the player is still within the zone.
				# Yes, I know this also happens in the left_zone function but this a "just in case" check
				var all_overlaps:Array = portal_area.get_overlapping_bodies()
				open = false
				for body_check:Node3D in all_overlaps:
					if body_check is PlayerController:
						open = true
				#Do animation here
			elif !must_be_interacted_with && body is CharacterBody3D:
				if !open:
					open = true 
			#Run animation status check
		#Probably make it play sounds when close

func left_zone(body):
	if !disabled && !dormant:
		if reacts_to_proximity:
			if body is PlayerController:
				open = false
				#Run animation status check

func activated(interactor: CharacterBody3D):
	if cinematic_portal:
		#Send a signal to player to run animation
		signal_manager.emit_signal("trigger_enter_portal", self)
		#Perhaps set a timer or wait for a signal to do the teleportation process?
		
	else:
		#Just activate portal
		signal_manager.emit_signal("teleporter_used", set_id, unique_portal_id, interactor)


func teleporter_collided(interactor):
	if interactor is CharacterBody3D:
		signal_manager.emit_signal("teleporter_used", set_id, unique_portal_id, interactor)

func receiveTeleportRequest(check_set_id, linked_portal_id, interactor:CharacterBody3D):
	if (set_id == check_set_id) && (unique_portal_id != linked_portal_id):
		print("Got here")
		interactor.global_position = global_position + exit_offset;
