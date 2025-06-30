class_name Inv_slot_helper
extends Button

@export var slot_index: int = -1 # disabled unless set
@export var item: Item = null
var signal_manager = VoidScreamers

func _ready():
	#connect("gui_input", selected_slot)
	print("Inv_slot_helper ready with slot index: ", slot_index)

func _gui_input(event):
	print(event)
	selected_slot(event)

func selected_slot(event: InputEvent):
	print("Slot selected: ", slot_index)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		signal_manager.emit_signal("selected_item", slot_index)
			
