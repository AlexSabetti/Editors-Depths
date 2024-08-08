class_name Item
extends Node3D

@export_category("Identifiers")
@export var hover_name:String
@export_category("Item Parameters")
@export var use_prompt:String
@export var destroyed_after_use: bool
@export var item_id:int
@export var scene_link:String

func show_hover_text() -> String:
	return ""

func destroy():
	queue_free()

@warning_ignore("unused_parameter")
func use(interactor: CharacterBody3D):
	return

@warning_ignore("unused_parameter")
func take_out(interactor:CharacterBody3D):
	return

@warning_ignore("unused_parameter")
func put_away(interactor:CharacterBody3D):
	return

@warning_ignore("unused_parameter")
func secondary_use(interactor:CharacterBody3D):
	return

