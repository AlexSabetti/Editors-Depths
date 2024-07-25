class_name UniqueRegion
extends Area3D

@export var region_title: String
@export var region_tie_id: int
@export var is_vertical_region: bool = false
@export_enum("Swimmable", "Pocket") var region_type: String = "Pocket"
var signal_manager = VoidScreamers

func _ready():
	if region_title == "":
		region_title = "Debug"
	self.connect("body_entered", on_enter)
	self.connect("body_exited", on_exit)

func on_enter(entity):
	if entity is PlayerMovementController:
		signal_manager.emit_signal("region_entered", region_title, is_vertical_region)
		print("entered")
		
func on_exit(entity):
	if entity is PlayerMovementController:
		signal_manager.emit_signal("region_exited", is_vertical_region)
		print("exited")
