class_name UnloadedObject

var data
var type: String
var pos: Vector3
var rot: Vector3
var scale: Vector3

var state

func get_contents() -> Array:
	var returnable: Array = [data, type, pos, rot, scale]
	return returnable

