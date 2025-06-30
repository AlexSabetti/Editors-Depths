class_name landmine
extends StaticBody3D

@onready var trigger_area: Area3D = $TriggerArea
@onready var explosion_spawner: Node3D = $Spawn
@export var explosion_scene: PackedScene
@export_group("Main Properties")
@export var damage: float
@export var explosion_radius: float
@export var knockback_force: float
@export var knockback_dir: Vector3 = Vector3(0, 0, 0)
@export var dmg_kb_mult: float = 1
@export_group("Extra Properties")
@export var explosion_expanding_speed: float = 0.5
@export var scale_by: float = 0.1
@export var debug_mode: bool = false

var has_triggered: bool = false
var payload: Dictionary
func _ready():
	trigger_area.connect("body_entered", spring)
	payload.get_or_add("damage", damage)
	payload.get_or_add("final_explosion_radius", explosion_radius)
	payload.get_or_add("scaling_speed", explosion_expanding_speed)
	payload.get_or_add("scale_by", scale_by)
	if knockback_force != 0:
		payload.get_or_add("knockback_force", knockback_force)
		payload.get_or_add("knockback_force_override", true)
	payload.get_or_add("dmg_kb_mult", dmg_kb_mult)
	if knockback_dir:
		payload.get_or_add("knockback_direction", knockback_dir)
		payload.get_or_add("knockback_dir_override", true)
	if debug_mode:
		payload.get_or_add("debug", debug_mode)

func spring(body):
	print(body)
	if body is entity and !has_triggered:
		var instance = explosion_scene.instantiate()
		add_child(instance)
		instance.global_position = explosion_spawner.global_position
		instance.read_payload(payload)
		has_triggered = true
		
	