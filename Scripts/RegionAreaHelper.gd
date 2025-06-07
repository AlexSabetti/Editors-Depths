class_name RegionAreaHelper
extends Area3D

@onready var region_node = get_parent()

func remove_active_scene():
	region_node.remove_active_scene()
