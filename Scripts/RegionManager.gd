class_name RegionManager
extends Node3D


var load_queue = []
var unload_queue = []
var unload_thread:Thread = Thread.new()
var load_thread:Thread = Thread.new()
var load_thread_active = false
var unload_thread_active = false

var load_queue_mutex: Mutex = Mutex.new()
var unload_queue_mutex: Mutex = Mutex.new()
var signal_manager: SignalBus = VoidScreamers

func _ready():
	signal_manager.connect("load_region", _load_region)
	signal_manager.connect("unload_region", _unload_region)

func _load_region(non_native_nodes, packed_scene_name, region_title, origin_node):
	print("Grabbing mutex")
	load_queue_mutex.lock()
	print("got mutex")
	# Critical Section
	load_queue.append({"non_native_nodes": non_native_nodes, "packed_scene_name": packed_scene_name, "region_title": region_title, "origin_node": origin_node})
	print("added to queue")
	print(load_queue)
	load_queue_mutex.unlock()

	if not load_thread.is_started():
		load_thread.start(_load_region_thread)
	else:
		load_thread.wait_to_finish()

func _unload_region(non_native_nodes, packed_scene_name, region_title, origin_node):
	
	print("Grabbing mutex")
	unload_queue_mutex.lock()
	print("got mutex")
	# Critical Section
	unload_queue.append({"non_native_nodes": non_native_nodes, "packed_scene_name": packed_scene_name, "region_title": region_title, "origin_node": origin_node})
	print("added to queue")
	print(unload_queue)
	unload_queue_mutex.unlock()
	
	if not unload_thread.is_started():
		unload_thread.start(_unload_region_thread)
	else:
		unload_thread.wait_to_finish()

func _load_region_thread():
	load_thread_active = true
	while load_queue.size() > 0:
		load_queue_mutex.lock()
		var task = load_queue.pop_front()
		load_region_data(task["non_native_nodes"], task["packed_scene_name"], task["region_title"], task["origin_node"])
		load_queue_mutex.unlock()
		
		
	
	print("Load thread finished")
	load_thread_active = false
	

func _unload_region_thread():
	unload_thread_active = true
	while unload_queue.size() > 0:
		unload_queue_mutex.lock()
		var task = unload_queue.pop_front()
		unload_region_data(task["non_native_nodes"], task["packed_scene_name"], task["region_title"])
		unload_queue_mutex.unlock()
		
	print("Unload thread finished")
	unload_thread_active = false

func load_region_data(non_native_nodes, packed_scene_name, region_title, origin_node):
	var non_native_nodes_data = load_from_file("res://Data/Regions/Saved_Non_Native_Nodes_" + region_title + ".json")
	if packed_scene_name:
		var packed_scene = load(packed_scene_name)
		if packed_scene:
			var instance = packed_scene.instantiate()
			origin_node.call_deferred("add_child", instance)
	if non_native_nodes_data:
		var nodes = deserialize_nodes(non_native_nodes_data)
		for n in nodes:
			origin_node.get_child(0).call_deferred("add_child", n)

func unload_region_data(non_native_nodes, packed_scene_name, region_title):
	var non_native_nodes_data = serialize_nodes(non_native_nodes)

	
	save_to_file("res://Data/Regions/Saved_Non_Native_Nodes_" + region_title + ".json", non_native_nodes_data)
	
		
	
func serialize_nodes(nodes):
	var serialized_data = []
	for n in nodes:
		serialized_data.append(serialize_node(n))
	return serialized_data

func serialize_node(node):
	var data = {}
	data["type"] = node.get_class()
	data["pos"] = node.global_transform.origin
	data["rot"] = node.rotation
	data["scale"] = node.scale
	if node is Interactable:
		data["state"] = node.get_state()
	node.queue_free()
	return data

func save_to_file(file_path, data):
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func load_from_file(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var data = file.get_as_text()
		file.close()
		return JSON.parse_string(data)
	return null

func deserialize_nodes(data):
	var nodes = []
	for nd in data:
		var n = deserialize_node(nd)
		if n:
			nodes.append(n)
	return nodes

func deserialize_node(data):
	var node = null
	if data["type"] == "TankWorldObject":
		node = TankWorldObject.new()
	if node:
		node.rotation = data["rot"]
		node.scale = data["scale"]
		node.global_transform.origin = data["pos"]
		if "state" in data:  
			node.set_state(data["state"])
	return node
