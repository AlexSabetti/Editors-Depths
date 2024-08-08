class_name TankWorldObject
extends OnGroundItem

@export var tank_name:String
@export var max_capacity:float
@export var cur_capacity:float
@export var rank:int
@export var gas_content:int
@export var tank_type:int


func load_payload(payload:Item):
	var tank:GasTankItem = payload
	tank_name = tank.tank_name
	object_name = tank.hover_name
	cur_capacity = tank.cur_capacity
	gas_content = tank.gas_content
	tank_type = tank.tank_type
	rank = tank.rank

func send_inv_form():
	return GasTankItem.new(rank, cur_capacity,tank_type,gas_content)

func get_hover_tip():
	var key_name = ""
	for inputevent: InputEvent in InputMap.action_get_events(prompt_action):
			var specific_key: InputEventKey
			specific_key = inputevent as InputEventKey

			key_name = OS.get_keycode_string(specific_key.keycode)
	var to_return = tank_name + "\n[" + key_name + "]"
	if  not can_interact:
		to_return = "In Use"
	return to_return
