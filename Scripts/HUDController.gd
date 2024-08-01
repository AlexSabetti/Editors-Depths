class_name HUDController
extends Control

@onready var info_box:VBoxContainer = get_node("MC/Main/Top/InfoBox")
@onready var depth_stats:Label = get_node("MC/Main/Top/InfoBox/DepthBox/Depth")
@onready var x_coord_stats:Label = get_node("MC/Main/Top/InfoBox/CoordBox/XCoords")
@onready var z_coord_stats:Label = get_node("MC/Main/Top/InfoBox/CoordBox/ZCoords")
@onready var h_region_title:Label = get_node("MC/Main/Top/InfoBox/HRegionBox/HRegion")
@onready var v_region_title:Label = get_node("MC/Main/Top/InfoBox/VRegionBox/VRegion")
@onready var air_bar:TextureProgressBar = get_node("MC/Main/Bottom/StatusBarBox/Vb/AirBar")
@onready var cor_bar:TextureProgressBar = get_node("MC/Main/Bottom/StatusBarBox/Vb/CorruptionBar")
@onready var hotbar_box:GridContainer = get_node("MC/Main/Bottom/HotbarBox")

@export var lag_coord_delay: float = 2
var can_update_coords = true
var standard_hotbar_box
var highlighted_hotbar_box

func _ready():
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


