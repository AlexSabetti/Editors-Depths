class_name Air_lock
extends Node3D

@onready var door_anim_player: AnimationPlayer = $AnimationPlayer
@onready var transition_fill_area: PocketZone = $TransitionFillArea
@onready var activation_area: Area3D = $ActivationArea

@export_category("Door specifics")
@export_group("Door A")
@onready var door_a: Air_lock_door = $DoorA
@export_subgroup("Door A states")
@export var door_a_open: bool = false
@export_subgroup("Beyond Door A")
@export_enum("Gas", "Liquid") var type_beyond_door_a: String = "Gas"
@export var modifiers_beyond_door_a: Array[String] = []
@export_group("Door B")
@onready var door_b: Air_lock_door = $DoorB 
@export_subgroup("Door B states")
@export var door_b_open: bool = false
@export_subgroup("Beyond Door B")
@export_enum("Gas", "Liquid") var type_beyond_door_b: String = "Gas"
@export var modifiers_beyond_door_b: Array[String] = []
@export_category("States")
@export var sealed: bool = true
@export var broken: bool = false
@export_category("Door specifics")
@export_group("Timings")
## How long it takes to seal the airlock
@export var sealing_time: float = 2.0
## How long it takes to undo the seal
@export var unsealing_time: float = 2.0
## How long it takes until it resets if the airlock isn't entered
@export var pressurizer_wait_time: float = 5.0
@export_group("Activation")
## Decides if the airlock is activated by paired buttons or is triggered by the player walking through one end
@export_enum("Auto", "Manual") var activation_type: String = "Manual"
@export_group("Pairings")
@export var paired_button: Interactable
var active: bool = false
@export_group("Transition Zone")
@export var cur_modifiers: Array[String] = []
@export_enum("Gas", "Liquid") var cur_type: String = "Gas" 

var sealing: bool = false
var signal_manager = VoidScreamers

func _ready():
	activation_area.connect("body_entered", start_sequence)
	door_anim_player.connect("animation_finished", finished_anim)
	door_b.connect("door_triggered", open_door_b)
	door_a.connect("door_triggered", open_door_a)
	if broken:
		sealed = false
		door_a_open = true
		door_b_open = true
	if door_a_open:
		door_anim_player.play("prepare_door_a")
	if door_b_open:
		door_anim_player.play("prepare_door_b")
	if !paired_button:
		activation_type = "Auto"

func open_door_a():
	if not sealing and not broken:
		door_a.can_interact = false
		if door_b_open:
			door_b.can_interact = false
			door_anim_player.play_backwards("open_door_b")
			await door_anim_player.animation_finished
			door_b_open = false
		door_anim_player.play("open_door_a")
		await door_anim_player.animation_finished
		door_a_open = true
		activate_sequence(door_b)
		
func open_door_b():
	if not sealing and not broken:
		door_b.can_interact = false
		door_a.can_interact = false
		if door_a_open:
			door_anim_player.play_backwards("open_door_a")
			await door_anim_player.animation_finished
			door_a_open = false
		door_anim_player.play("open_door_b")
		await door_anim_player.animation_finished
		door_b_open = true
		activate_sequence(door_a)

func activate_sequence(door_to_open: Interactable):
	door_to_open.can_interact = false

func start_sequence(body):
	if active: 
		return
	if body is CharacterBody3D:
		sealing = true
		active = true
		if door_a_open:
			door_anim_player.play_backwards("open_door_a")
			await door_anim_player.animation_finished
			door_a_open = false
			await get_tree().create_timer(sealing_time).timeout
			var wait_timer: SceneTreeTimer = get_tree().create_timer(pressurizer_wait_time)
			transition_fill_area.set_type(type_beyond_door_b, modifiers_beyond_door_b)
			while wait_timer.time_left > 0:
				await wait_timer.timeout
			await get_tree().create_timer(unsealing_time).timeout
			door_anim_player.play("open_door_b")
			await door_anim_player.animation_finished
			door_b_open = true
			door_a.can_interact = true
			sealing = false
			active = false
		elif door_b_open:
			door_anim_player.play_backwards("open_door_b")
			await door_anim_player.animation_finished
			door_b_open = false
			await get_tree().create_timer(sealing_time).timeout
			var wait_timer: SceneTreeTimer = get_tree().create_timer(pressurizer_wait_time)
			transition_fill_area.set_type(type_beyond_door_a, modifiers_beyond_door_a)
			
			while wait_timer.time_left > 0:
				await wait_timer.timeout
			await get_tree().create_timer(unsealing_time).timeout
			door_anim_player.play("open_door_a")
			await door_anim_player.animation_finished
			door_a_open = true
			door_b.can_interact = true
			sealing = false
			active = false
	


func finished_anim(_anim_name: String):
	if door_a_open:
		door_a.can_interact = true
	else:
		door_b.can_interact = true
	if door_b_open:
		door_b.can_interact = true
	else:
		door_a.can_interact = true
	
func attempt_reset():
	if not sealing and not active:
		if door_a_open:
			door_anim_player.play_backwards("open_door_a")
		elif door_b_open:
			door_anim_player.play_backwards("open_door_b")
	
