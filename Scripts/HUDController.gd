class_name HUDController
extends Control

@onready var info_box:VBoxContainer = get_node("Main/Top/Mc/InfoBox")
@onready var depth_stats:Label = get_node("Main/Top/Mc/InfoBox/DepthBox/Depth")
@onready var x_coord_stats:Label = get_node("Main/Top/Mc/InfoBox/CoordBox/XCoords")
@onready var z_coord_stats:Label = get_node("Main/Top/Mc/InfoBox/CoordBox/ZCoords")
@onready var h_region_title:Label = get_node("Main/Top/Mc/InfoBox/HRegionBox/HRegion")
@onready var v_region_title:Label = get_node("Main/Top/Mc/InfoBox/VRegionBox/VRegion")
@onready var air_bar:TextureProgressBar = get_node("Main/Bottom/StatusBarBox/Vb/AirBar")
@onready var cor_bar:TextureProgressBar = get_node("Main/Bottom/StatusBarBox/Vb/CorruptionBar")

@export var lag_coord_delay: float = 2
var can_update_coords = true
func _ready():
	info_box.visible = false
func show_coords():
	var coord_box = info_box.get_node("CoordBox") as HBoxContainer
	coord_box.visible = !visible

func show_depth():
	var depth_box = info_box.get_node("DepthBox") as HBoxContainer
	depth_box.visible = !visible



