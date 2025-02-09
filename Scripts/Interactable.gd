class_name Interactable
extends Node3D

@export var object_name: String
@export var prompt_action: String
@export var can_interact: bool = true
@export var interact_prompt: String

## To be overrided, should be used for interaction, not pickup
@warning_ignore("unused_parameter")
func activated(interactor: CharacterBody3D):
	return false

## To be overrided
func get_hover_tip() -> String:
	return ""

## To be overrided
func get_state():
	return null