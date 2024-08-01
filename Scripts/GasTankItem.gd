class_name GasTankItem
extends Item

var tank_name:String
var max_capacity:float
var cur_capacity:float
var rank:int
var gas_content:int
var tank_type:int

var held_model:PackedScene

func _init(tank_rank:int, capacity:float, tank_build:int, tank_content:int):
	cur_capacity = capacity
	rank = tank_rank
	tank_type = tank_build
	var gas_name = get_proper_gas_name(tank_content)
	if tank_build == 0:
		max_capacity = 1000.0 * tank_rank
		tank_name = gas_name + " | Standard"
	elif tank_build == 1:
		max_capacity = 150.0 * tank_rank
		tank_name=gas_name + " | Reinforced"
	elif tank_build == 2:
		max_capacity = 100.0 * tank_rank
		tank_name=gas_name + " | Anti-Corrosive"

	if capacity > max_capacity:
		cur_capacity = max_capacity

func is_full() -> bool:
	if(cur_capacity == max_capacity):
		return true
	else: 
		return false

func get_proper_gas_name(gas_id) -> String:
	if gas_id == -1:
		return "Void Mist"
	elif gas_id == 0:
		return "Oxygen"
	elif gas_id == 1:
		return "HCI Mist"
	elif gas_id == 2:
		return "H2"
	else:
		return "Not Implimented"

func secondary_use(interactor: CharacterBody3D):
	if interactor is PlayerMovementController:
		var player:PlayerMovementController = interactor
		if player.has_connected_tank:
			var swap = player.gas_tank_slot
			player.gas_tank_slot = self
			player.inventory[player.hover_on_slot] = swap
		else:
			player.gas_tank_slot = self
			player.inventory[player.hover_on_slot] = null

func show_hover_text():
	return tank_name