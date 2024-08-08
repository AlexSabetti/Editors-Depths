class_name OnGroundItem
extends Interactable

var typing_of

## Simple trash function
func destroy():
	queue_free()
	return

func send_inv_form():
	return

@warning_ignore("unused_parameter")
func load_payload(payload:Item):
	return