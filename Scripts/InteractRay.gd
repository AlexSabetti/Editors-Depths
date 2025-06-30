class_name InteractRay
extends RayCast3D
# NOTE: I learned this way of doing interaction from the youtuber Nagi, the video link is provided below:
	# https://youtu.be/An3uHrAoHRw?si=CzLhaeNTjGiajpCP
	# Thanks for the tutorial!
var proper_owner: PlayerMovementController
var what_am_i_looking_at: Label

func _ready():
	proper_owner = get_parent().get_parent().get_parent() #Ideally our result should be the Player Character
	what_am_i_looking_at = proper_owner.get_node("Pivot/Eyes/HUD/MC/Center/Prompt")

@warning_ignore("unused_parameter")
func _physics_process(delta):
	if is_colliding():
		var collision = get_collider()
		if collision is Interactable:
			what_am_i_looking_at.text = collision.get_hover_tip()

			if Input.is_action_just_pressed(proper_owner.interact) and collision.can_interact:
				# interact uses activate as its method
				print("Interacted")
				collision.activated(proper_owner)
			if collision is OnGroundItem:
				if Input.is_action_just_pressed(proper_owner.pick_up) and collision.can_interact:
					# pickup uses pickup as its method (duh)
					pickup(collision)
		else:
			what_am_i_looking_at.text = ""
	else:
		what_am_i_looking_at.text = ""

func pickup(collision:OnGroundItem):
	if proper_owner.hotbar[proper_owner.hover_on_slot] == null:

			proper_owner.hotbar[proper_owner.hover_on_slot] = collision.send_inv_form()
			proper_owner.hud.add_item_slot_texture(proper_owner.hotbar[proper_owner.hover_on_slot].item_id, proper_owner.hover_on_slot)
			proper_owner.refresh_holding_2()
			# proper_owner.currently_holding = proper_owner.inventory[proper_owner.hover_on_slot]
			# print(proper_owner.currently_holding)
			# proper_owner.currently_holding.take_out(proper_owner)
			# proper_owner.hud.change_inv_hb_text(proper_owner.currently_holding.hover_name)
			collision.destroy()
	else:
		var i = 0
		for slot in proper_owner.inventory:
			if slot == null:
				proper_owner.inventory[i] = collision.send_inv_form()
				proper_owner.hud.add_item_slot_texture(proper_owner.inventory[i].item_id, i)
				collision.destroy()
			else:
				i += 1
		#if we get here, no spots, so do nothing
		return
	
