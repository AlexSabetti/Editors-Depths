class_name Air_lock_door
extends Interactable
signal door_triggered

func activated(interactor: CharacterBody3D):
	emit_signal("door_triggered")

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