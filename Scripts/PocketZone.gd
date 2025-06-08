class_name PocketZone
extends Area3D

@export_category("Contents")


@export_group("Material traits")
@export var is_gas: bool = true

@export_subgroup("Gas modifiers")
@export var breathable: bool = true
@export var caustic: bool = false
@export var explosive: bool = false
@export var corrosive: bool = false
@export var suppressing: bool = false

@export_subgroup("Liquid modifiers")
@export var cloud_water: bool = false
@export var clear_water: bool = true
@export var acidic: bool = false
@export var corrupt: bool = false



@onready var collider: CollisionShape3D = $CollisionShape3D
@export_category("Collider States")
@export var locked_in_place: bool = true
@export var collider_size: Vector3 = Vector3(-1, -1, -1)
#Perhaps impliment a particle system?
func _get_property_list():
	var list = []
	if is_gas:
		
		if not corrosive and not caustic and not suppressing:
			list.append({name = "breathable", type = TYPE_BOOL})

		list.append({name = "explosive", type = TYPE_BOOL})
		if not breathable:
			list.append({name = "caustic", type = TYPE_BOOL})
			list.append({name = "corrosive", type = TYPE_BOOL})
			list.append({name = "suppressing", type = TYPE_BOOL})
	else:
		if not cloud_water and not corrupt:
			list.append({name = "clear_water", type = TYPE_BOOL})
		if not clear_water:
			list.append({name = "cloud_water", type = TYPE_BOOL})
			list.append({name = "corrupt", type = TYPE_BOOL})
		list.append({name = "acidic"})
	
func _ready():
	if collider_size != Vector3(-1, -1, -1):
		collider.shape.extents = collider_size

func set_type(type: String, modifiers: Array[String]):
	print("Modifiers: ", modifiers)
	if type == "Gas":
		set_collision_layer_value(5, false)
		set_collision_layer_value(6, true)

		is_gas = true
		breathable = "breathable" in modifiers
		caustic = "caustic" in modifiers
		explosive = "explosive" in modifiers
		corrosive = "corrosive" in modifiers
		suppressing = "suppressing" in modifiers
	elif type == "Liquid":
		set_collision_layer_value(6, false)
		set_collision_layer_value(5, true)
		is_gas = false
		clear_water = "clear_water" in modifiers
		cloud_water = "cloud_water" in modifiers
		corrupt = "corrupt" in modifiers
		acidic = "acidic" in modifiers
	debug_print()

func debug_print():
	print("Pocket Zone Type:" + (" Gas" if is_gas else " Liquid"))
	if is_gas:
		print("Breathable: " + str(breathable))
		print("Caustic: " + str(caustic))
		print("Explosive: " + str(explosive))
		print("Corrosive: " + str(corrosive))
		print("Suppressing: " + str(suppressing))
	else:
		print("Clear Water: " + str(clear_water))
		print("Cloud Water: " + str(cloud_water))
		print("Corrupt: " + str(corrupt))
		print("Acidic: " + str(acidic))
