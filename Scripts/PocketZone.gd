class_name PocketZone
extends Area3D

@export_category("Air type")

## Until my lazy ass turns this into an enum, the following decides what gas makes up the pocket zone's atmosphere:
## 0 stands for Oxygen
## 1 stands for toxic / caustic gasses
## 2 stands for toxic / caustic gasses that are explosive
## 3 stands for corosive gasses
@export var gas_within:int

#Perhaps impliment a particle system?
