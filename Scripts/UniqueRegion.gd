class_name UniqueRegion
extends Area3D

@export var region_title: String
@export var region_tie_id: int
@export var is_vertical_region: bool = false
@export_enum("Swimmable", "Pocket") var region_type: String = "Pocket"

@export_group("Region Scene")
@export var packed_scene_name: String
@export var displayed_scene : PackedScene

var non_native_nodes: Array = []

var signal_manager = VoidScreamers

func _ready():
	if region_title == "":
		region_title = "Debug"
	packed_scene_name = displayed_scene.resource_path
	print(packed_scene_name)
	self.connect("body_entered", on_enter)
	self.connect("body_exited", on_exit)

func on_enter(entity):
	if entity is PlayerMovementController:
		signal_manager.emit_signal("region_entered", region_title, is_vertical_region)
		signal_manager.emit_signal("load_region", non_native_nodes, packed_scene_name, region_title, self)
		 
		print("entered")
		
func on_exit(entity):
	if entity is PlayerMovementController:
		packed_scene_name = displayed_scene.resource_path
		print(packed_scene_name)
		var n = get_child(0)
		for node in n.get_children():
			var stored_object: UnloadedObject
			if node is TankWorldObject:
				
				stored_object.data = node.send_inv_form()
				stored_object.rot = node.rotation
				stored_object.scale = node.scale
				stored_object.type = "TankWorldObject"
				stored_object.pos = node.global_transform.origin
				non_native_nodes.append(stored_object)
			# Do more here when more placed objects are added
		


		signal_manager.emit_signal("region_exited", is_vertical_region)
		signal_manager.emit_signal("unload_region", non_native_nodes, packed_scene_name, region_title, self)
		print("exited")
