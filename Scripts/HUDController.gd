class_name HUDController
extends Control

@onready var info_box:VBoxContainer = get_node("MC/Main/Top/InfoBox")
@onready var depth_stats:Label = get_node("MC/Main/Top/InfoBox/DepthBox/Depth")
@onready var x_coord_stats:Label = get_node("MC/Main/Top/InfoBox/CoordBox/XCoords")
@onready var z_coord_stats:Label = get_node("MC/Main/Top/InfoBox/CoordBox/ZCoords")
@onready var h_region_title:Label = get_node("MC/Main/Top/InfoBox/HRegionBox/HRegion")
@onready var v_region_title:Label = get_node("MC/Main/Top/InfoBox/VRegionBox/VRegion")

# Bars
@onready var air_bar:TextureProgressBar = get_node("MC/Main/Bottom/StatusBarBox/Vb/AirBar")
@onready var cor_bar:TextureProgressBar = get_node("MC/Main/Bottom/StatusBarBox/Vb/CorruptionBar")
# Hotbar container
@onready var hotbar_box:GridContainer = get_node("MC/Main/Bottom/HotbarBox")
# Text that shows up when an item is selected in the hotbar
@onready var inv_select_text:Label = get_node("MC/Main/Top/InvHoverText")
@export_group("Delay Settings")
@export var lag_coord_delay: float = 2

@onready var inv_box:Panel = get_node("MC/Main/Middle/Panel")
var is_paused: bool = false

@onready var signal_manager = VoidScreamers

var item_texture_dict:Dictionary = {
	0 : "res://Materials/InvGasTankItem.png"
}
var can_update_coords = true
var standard_hotbar_box
var highlighted_hotbar_box
var cursor_inventory: Item = null

func _ready():
	process_mode = Control.PROCESS_MODE_ALWAYS
	signal_manager.connect("selected_item", selected_inv_slot)
	signal_manager.connect("unpause", respond_to_unpause)
	signal_manager.connect("pause", respond_to_pause)

	standard_hotbar_box = load("res://Materials/HotbarSlotAttempt1.png")
	highlighted_hotbar_box = load("res://Materials/HotBarSlotHoveredAttempt1.png")
	info_box.visible = false

func show_coords():
	var coord_box = info_box.get_node("CoordBox") as HBoxContainer
	coord_box.visible = !visible

func show_depth():
	var depth_box = info_box.get_node("DepthBox") as HBoxContainer
	depth_box.visible = !visible

func highlight_hover_slot(slot_prior:int, slot_now:int):
	hotbar_box.get_child(slot_prior).texture = standard_hotbar_box
	hotbar_box.get_child(slot_now).texture = highlighted_hotbar_box

func change_inv_hb_text(new_text:String):
	inv_select_text.text = new_text

func add_item_slot_texture(item_id:int, slot:int):
	if item_id == -13:
		var text_rect: TextureRect = hotbar_box.get_child(slot).get_child(0)
		text_rect.texture = null
	else:
		var text_rect: TextureRect = hotbar_box.get_child(slot).get_child(0)
		text_rect.texture = load(item_texture_dict.get(item_id))

func add_item_to_slot(item_type:Item, slot:int):
	add_item_slot_texture(item_type.item_id, slot)
	hotbar_box.get_child(slot).item = item_type

func remove_item_from_slot(slot: int):
	var item_in_hotbar = hotbar_box.get_child(slot)
	remove_item_sprite_from_hotbar(slot)
	item_in_hotbar.item = null

func swap_item_slot_texture(item_type:Item, slot:int):
	var text_rect: TextureRect = hotbar_box.get_child(slot).get_child(0)
	text_rect.texture = load(item_texture_dict.get(item_type.item_id))

func remove_item_sprite_from_hotbar(slot:int):
	var text_rect: TextureRect = hotbar_box.get_child(slot)
	text_rect.get_child(0).texture = null
	text_rect.item = null

func remove_item_sprite_from_inv(slot:int):
	var slot_rect = inv_box.get_child(slot).get_child(0)
	slot_rect.texture = null

func add_item_sprite_to_inv(item_type:Item, slot: int):
	var slot_rect = inv_box.get_child(slot).get_child(0)
	slot_rect.texture = load(item_texture_dict.get(item_type.item_id))


func respond_to_pause():
	is_paused = true
	info_box.hide()
	if inv_box.visible:
		inv_box.hide()
		inv_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hotbar_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
func respond_to_unpause():
	is_paused = false
	# Finish when pause menu is made

func toggle_inv():
	if !inv_box.visible:
		print("Showing inventory box")
		inv_box.show()
		inv_box.mouse_filter = Control.MOUSE_FILTER_STOP
		hotbar_box.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		print("Hiding inventory box")
		inv_box.hide()
		inv_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hotbar_box.mouse_filter = Control.MOUSE_FILTER_IGNORE

func selected_inv_slot(slot: int):
	if slot > hotbar_box.get_child_count() - 1:
		slot -= hotbar_box.get_child_count()

		var slot_node = inv_box.get_child(slot)
		var slot_item = slot_node.item

		if cursor_inventory == null and slot_item != null:
			cursor_inventory = slot_item
			remove_item_sprite_from_inv(slot)
			print("Picked item from inv at slot: ", slot)
		elif cursor_inventory != null and slot_item == null:
			slot_node.item = cursor_inventory
			add_item_sprite_to_inv(cursor_inventory, slot)
			cursor_inventory = null
			print("Placed item in inv at slot: ", slot)
		elif cursor_inventory != null and slot_item != null:
			if cursor_inventory.item_id == slot_item.item_id:
				var remainder = slot_item.add_to_stack(cursor_inventory.cur_stack_size)
				if remainder > 0:
					cursor_inventory.cur_stack_size = remainder
				else: 
					cursor_inventory = null
			else:
				print("Cannot stack items, swapping")
				var temp = cursor_inventory
				cursor_inventory = slot_item
				slot_node.item = temp
				add_item_sprite_to_inv(cursor_inventory, slot)
	else:
		var slot_node = hotbar_box.get_child(slot)
		var slot_item = slot_node.item

		if cursor_inventory == null and slot_item != null:
			cursor_inventory = slot_item
			remove_item_sprite_from_hotbar(slot)
			print("Picked item from hotbar at slot: ", slot)
		elif cursor_inventory != null and slot_item == null:
			slot_node.item = cursor_inventory
			add_item_slot_texture(cursor_inventory.item_id, slot)
			cursor_inventory = null
			print("Placed item in hotbar at slot: ", slot)
		elif cursor_inventory != null and slot_item != null:
			if cursor_inventory.item_id == slot_item.item_id:
				var remainder = slot_item.add_to_stack(cursor_inventory.cur_stack_size)
				if remainder > 0:
					cursor_inventory.cur_stack_size = remainder
				else: 
					cursor_inventory = null
			else:
				print("Cannot stack items, swapping")
				var temp = cursor_inventory
				cursor_inventory = slot_item
				slot_node.item = temp
				swap_item_slot_texture(cursor_inventory, slot)
		signal_manager.emit_signal("update_hotbar", slot)
