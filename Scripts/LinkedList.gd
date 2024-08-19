class_name LinkedList

var head:ListNode = null
var list_size = 0

func _init():
	print("LinkedList created")

func insert_at_beginning(data):
	var new_node = ListNode.new(data)
	if head == null:
		head = new_node
	else:
		new_node.next = head
		head.prev = new_node
		head = new_node
	list_size += 1

func add(data):
	var new_node = ListNode.new(data)
	if head == null:
		head = new_node
	else:
		var trolley:ListNode = head
		while trolley.next != null:
			trolley = trolley.next
		trolley.next = new_node
		new_node.prev = trolley
	list_size += 1

func remove(index):
	var node_to_remove:ListNode = find_list_node(index)
	var val
	if node_to_remove == null:
		return
	else:
		val = node_to_remove.data
		if index == 0:
			if head.next != null:
				head = head.next
				head.prev.next = null
				head.prev = null
			else:
				head = null
			return val
		else:
			if node_to_remove.prev != null:
				node_to_remove.prev.next = node_to_remove.next
				node_to_remove.next.prev = node_to_remove.prev
				node_to_remove.prev = null
				node_to_remove.next = null
			else:
				node_to_remove.next.prev = null
				node_to_remove.prev = null
				node_to_remove.next = null
			return val 

func set_value(index, data):
	var node_to_set:ListNode = find_list_node(index)
	if node_to_set == null:
		return
	else:
		node_to_set.data = data

func get_list_node(index):
	return find_list_node(index)
	
func size():
	return list_size

func find_list_node(index) -> ListNode:
	var trolley:ListNode = head
	var place = 0
	if head == null:
		return null
	if place == index:
		return head
	else:
		while trolley.next != null and place != index:
			trolley = trolley.next
			place += 1
		if place == index:
			return trolley
		else:
			return null