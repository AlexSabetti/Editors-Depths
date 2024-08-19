class_name SegmentHandler
#Grappling Hook Minecraft Mod project by Nyfaria translated from Java to GDScript, and hopefully when finished, works in an entirely seperate Engine
#https://github.com/Nyfaria/grapplemod/blob/1.18/main/java/com/yyon/grapplinghook/entities/grapplehook/SegmentHandler.java#L31

var segments_grapple:LinkedList
var segments_top:LinkedList
var segments_bottom:LinkedList

var impact_local:Vector3

var prev_hook_local:Vector3
var prev_player_local:Vector3

var cord_length:float

func _init(hook_local, player_local):
	segments_grapple = LinkedList.new()
	segments_grapple.add(hook_local)
	segments_grapple.add(player_local)
	
	prev_hook_local = hook_local
	prev_player_local = player_local
	
	segments_bottom = LinkedList.new()
	segments_bottom.add(null)
	segments_bottom.add(null)
	
	segments_top = LinkedList.new()
	segments_top.add(null)
	segments_top.add(null)

func force_set_pos(hook_local, player_local):
	prev_hook_local = hook_local
	prev_player_local = player_local
	segments_grapple.set_value(0, hook_local)
	segments_grapple.set_value(segments_grapple.size() - 1, player_local)

func update_pos(hook_local, player_local, cord_len):
	segments_grapple.set_value(0, hook_local)
	segments_grapple.set_value(segments_grapple.size() - 1, player_local)
	cord_length = cord_len

#While good practice, not usable. 

