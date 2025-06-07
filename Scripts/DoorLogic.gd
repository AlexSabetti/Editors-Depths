class_name DoorLogic
extends Interactable

@onready var door_anim_player: AnimationPlayer = $AnimationPlayer
@export_category("States")
@export var open: bool = false
@export var locked: bool = false

@export_category("Interact Requirements")
@export var requirement: String
@export var requires_item_to_unlock: bool = false

func _ready():
	door_anim_player.connect("animation_finished", finished_moving)
	if open:
		door_anim_player.play("activate_door")

func activated(interactor: CharacterBody3D):
	if open:
		can_interact = false
		open = false
		close_door()
	else:
		if interactor is PlayerMovementController:
			var player:PlayerMovementController = interactor
			if requires_item_to_unlock:
				if player.inventory[player.hover_on_slot] != null:
					var item_slot = player.inventory[player.hover_on_slot]
					if item_slot.hover_name == requirement:
						if item_slot.destroyed_after_use:
							item_slot.destroy()
							player.inventory[player.hover_on_slot] = null
						open_door()
			else:
				open_door()

func close_door():
	can_interact = false
	door_anim_player.play_backwards("activate_door")
	open = false

func open_door():
	can_interact = false
	door_anim_player.play("activate_door")
	open = true

func finished_moving(_anim_name):
	can_interact = true

func get_hover_tip() -> String:
	var key_name = ""
	for inputevent: InputEvent in InputMap.action_get_events(prompt_action):
			var specific_key: InputEventKey
			specific_key = inputevent as InputEventKey

			key_name = OS.get_keycode_string(specific_key.keycode)
	var to_return = object_name + "\n[" + key_name + "]"
	if  not can_interact:
		to_return = "In Use"
	return to_return
   