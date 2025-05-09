class_name OOB_Return
extends Area3D

func _ready():
	self.connect("body_entered", on_enter)

func on_enter(entity):
	