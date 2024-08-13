class_name KineticRifle
extends Item

@export_category("Weapon Stats")
@export var firing_spd:float
@export var int_dmg: float
@export var change_state_time: float
@export var reload_time: float
@export_category("Ammo Specifics")
@export var ammo_type:int

var max_ammo:int
var current_ammo:int
