class_name GasPressurizer
extends Interactable

var input_slot:GasTankItem
var output_slot:GasTankItem

@export_category("Machine Stats")
@export var level:int = 0
@export var time_modifier:float = 0.025
@export var standard_pressurize_time:float = 40.0
@export var swapping_grace_period:float = 1.0
var coroutine_in_progress:bool = false

var active:bool = false
var grace_period_active = false
var draw_from_surroundings:bool = true
@onready var gas_input_hatch:Area3D = $InputSection

@warning_ignore("unused_parameter")
func activated(interactor: CharacterBody3D):
	if interactor is PlayerMovementController:
		var player:PlayerMovementController = interactor

		if(output_slot != null):
			if(player.add_to_inventory(output_slot)):
				output_slot = null
			return
		if(input_slot != null):
			if(player.add_to_inventory(input_slot)):
				input_slot = null
				active = false
				grace_period_active = false
			return
		if(player.inventory[player.hover_on_slot] is GasTankItem):
			input_slot = player.remove_from_inventory(player.hover_on_slot)
			grace_period_active = true
			

func grace_period_coroutine():
	await get_tree().create_timer(swapping_grace_period).timeout
	if !grace_period_active:
		return
	else:
		check_contents()

func check_contents():
	var to_draw_from:Array = gas_input_hatch.get_overlapping_areas()
	for zone:Area3D in to_draw_from:
		if zone is PocketZone:
			if zone.gas_within == input_slot.gas_content:
				active = true
				refill_tank()
			else:
				print("explode here")

func refill_tank():
	var per_max = (input_slot.max_capacity / (40.0 / (1 + (level * time_modifier))))
	while(active):
		if input_slot.cur_capacity >= input_slot.max_capacity:
			input_slot.cur_capacity = input_slot.max_capacity
			active = false
			output_slot = input_slot
			input_slot = null
			return
		else:
			refill_coroutine(per_max)

				
func refill_coroutine(to_fill):
	if coroutine_in_progress:
		return
	else:
		coroutine_in_progress = true
		await get_tree().create_timer(1).timeout
		input_slot.cur_capacity += to_fill
		coroutine_in_progress = false
