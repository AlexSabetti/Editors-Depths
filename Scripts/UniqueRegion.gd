class_name UniqueRegion
extends Node3D

@export var region_title: String
@export var region_tie_id: int
@export var is_vertical_region: bool = false
@export_enum("Swimmable", "Pocket") var region_type: String = "Pocket"

@export_group("Region Scene")
@export var packed_scene_name: String
@export var displayed_scene : PackedScene
@export var is_empty: bool = false

@onready var load_area: Area3D = $LoadArea
@onready var region_area: Area3D = $RegionArea
@onready var object_storage : Node3D = $ObjectTab

var non_native_nodes: Array = []
var active_scene: Node3D
var signal_manager = VoidScreamers

func _ready():
	if region_title == "" and displayed_scene == null:
		region_title = "Debug"
		is_empty = true
	if not is_empty:

		packed_scene_name = displayed_scene.resource_path
		print(packed_scene_name)
		load_area.connect("body_entered", on_enter_far)
		load_area.connect("body_exited", on_exit_far)
	region_area.connect("body_entered", on_enter_near)
	region_area.connect("body_exited", on_exit_near)

func on_enter_far(entity):
	if entity is PlayerMovementController:
		signal_manager.emit_signal("load_region", non_native_nodes, packed_scene_name, region_title, self)
		print(active_scene)
		active_scene = get_child(get_child_count() - 1)
		print("Player has entered, now loading...")

func on_enter_near(entity):
	if entity is PlayerMovementController:
		signal_manager.emit_signal("region_entered", region_title, is_vertical_region)
		print("Player has entered inner zone")

func on_exit_near(entity):
	if entity is PlayerMovementController:
		signal_manager.emit_signal("region_exited", is_vertical_region)
		print("Player has exited inner zone")
		
func on_exit_far(entity):
	if entity is PlayerMovementController:
		packed_scene_name = displayed_scene.resource_path
		print(packed_scene_name)
		
		for node in object_storage.get_children():
			var stored_object: UnloadedObject  = UnloadedObject.new()
			if node is TankWorldObject:
				
				stored_object.data = node.send_inv_form()
				stored_object.rot = node.rotation
				stored_object.scale = node.scale
				stored_object.type = "TankWorldObject"
				stored_object.pos = node.global_transform.origin
				non_native_nodes.append(stored_object)
			# Do more here when more placed objects are added
		


		print(get_children())
		signal_manager.call_deferred("emit_signal", "unload_region", non_native_nodes, packed_scene_name, region_title, active_scene)
		active_scene.queue_free()
		print("exited")
