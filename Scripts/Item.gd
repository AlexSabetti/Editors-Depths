class_name Item
extends Node3D

@export_category("Identifiers")
@export var hover_name:String
@export_category("Item Parameters")
@export var use_prompt:String
@export var destroyed_after_use: bool
@export var item_id:int
@export var scene_link:String
@export var stackable: bool = false
@export var max_stack_size:int = 1
@export var cur_stack_size: int = 0  

var stack_count_history: Array = []

var use_anim_name
var secondary_use_anim_name
var take_out_anim_name
var put_away_anim_name 

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

func select_and_split_stack() -> int:
	if not stackable:
		# remove the item from inventory and place it in cursor inventory
		return 1
	else:
		if cur_stack_size > 1:
			var split_size = int(cur_stack_size / 2)
			cur_stack_size -= split_size
			return split_size
		else:
			return 1

func select_stack()-> int:
	var to_return = cur_stack_size
	cur_stack_size = 0
	stack_count_history.append(to_return)
	return to_return

func add_to_stack(amount: int) -> int:
	stack_count_history.append(cur_stack_size)
	if not stackable:
		return 1
	else:
		if cur_stack_size + amount <= max_stack_size:
			cur_stack_size += amount
			return 0
		else:
			var overflow = cur_stack_size + amount - max_stack_size
			cur_stack_size = max_stack_size
			return overflow

func subtract_from_stack(amount: int) -> int:
	stack_count_history.append(cur_stack_size)
	if not stackable:
		cur_stack_size = 0
		return 1
	else:
		if cur_stack_size - amount >= 0:
			cur_stack_size -= amount
			return 0
		else:
			var underflow = amount - cur_stack_size
			cur_stack_size = 0
			return underflow


	

