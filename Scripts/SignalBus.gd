class_name SignalBus
extends Node

signal region_entered(title:String, is_vertical_region:bool)
signal region_exited(is_vertical_region:bool)

signal load_region(non_native_nodes:Array, inner_nodes:Dictionary)
signal unload_region(non_native_nodes:Array, inner_nodes:Dictionary)

#signal trigger_enter_portal(entered_portal:Portal)
signal teleporter_used(set_id:int, unique_portal_id:int, interactor:CharacterBody3D)

