class_name entity
extends CharacterBody3D

@export var debug_name: String
@export var debug_description: String

# This is really only used as an identifier, entities will extend this from their own custom scripts

func display_debug_info():
	var info = "Entity Debug Info:\n"
	info += "Name: " + debug_name + "\n"
	info += "Description: " + debug_description + "\n"
	print(info)

func deal_damage(damage: float):
	print("If this prints, this function was not overridden")

func apply_knockback(direction: Vector3, force: float):
	print("If this prints, this function was not overridden")