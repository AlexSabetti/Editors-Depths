class_name PlayerMovementController
extends CharacterBody3D

####
# The majority of the physics related movement code (Not the swimming code, that is my own)
# was written by BirDt -> https://github.com/BirDt
# who worked off of the technical write-up by Flafla2 on source movement and bhopping.
# Hope you don't mind, fellas
####

@export_category("Movement Toggles")
@export var look_enabled : bool = true : 
	get:
		return movement_enabled
	set(val):
		look_enabled = val
		update_mouse_mode()
@export var movement_enabled: bool = true
@export var jump_when_held: bool = false

@export_category("Inputs")
@export var move_forward: String
@export var move_backward: String
@export var move_left: String
@export var move_right: String
@export var jump: String
@export var hotbar_up: String
@export var hotbar_down: String
@export var left_click_use : String
@export var right_click_use : String
@export var interact : String
@export var switch_light : String
@export var pick_up : String
@export var drop_holding : String

@export_category("Movement Variables")
@export var gravity : float = 30
@export var ground_acc : float = 250
@export var air_acc : float = 85
@export var max_ground_vel: float = 10
@export var max_air_vel: float = 1.5
@export var jump_force: float = 1
@export var friction: float = 6
@export var bhop_timing_frames: int = 2
@export var additive_bhop : bool = true
@export var mouse_sens: float = 1

@export_category("Controlled Nodes")
#Hook up all status stuff later
@onready var pivot = get_node("Pivot")
@onready var char_cam: Camera3D = get_node("Pivot/Eyes")
@onready var hud: HUDController = get_node("Pivot/Eyes/HUD")
@onready var anim_manager: AnimationPlayer = get_node("AnimationPlayer")
@onready var underwater_overlay: MeshInstance3D = get_node("Pivot/Eyes/LiquidOverlay")
@onready var damage_overlay: MeshInstance3D = get_node("Pivot/Eyes/DamageOverlay")
@onready var drop_local: Node3D = get_node("Pivot/DropLocal")
@onready var search_light: SpotLight3D = get_node("Pivot/Eyes/SearchLight")

@export_category("Debug")
@export var enable_debug : bool = false
@export var debug_wishdir_raycast : RayCast3D
@export var debug_vel_raycast : RayCast3D

@export_category("Swimming Properties")
@export var base_swim_speed: float = 1.2
@export var swim_speed_decay: float = 0.02
@export var swim_to_air_launch_speed: float = 1.5
@export var wading_speed: float = 0.8
@export var boost_downtime: float = 1.0
@export var boost_multiplier: float = 1.2
@export var underwater_friction: float = 80.0
@export var forced_sink_multiplier: float = 10.0

@export_category("Health Properties")
@export var initial_max_health: float = 100.0
@export var corruption_damage: float = 5.0
@export var corruption_wait_time: float = 2.0
@export var fall_damage_threshold: float = -25
@export var fall_damage_modifier: float = 0.58

@export_category("Air Properties")
@export var base_air_supply: float = 100.0
@export var draw_air_interval: float = 5.0
@export var draw_air_interval_modifier: float = 1
@export var draw_air_amount: float = 1.0
@export var draw_air_amount_modifier: float = 1

@export_category("Startup Settings")
@export var play_startup_anim: bool = true

@export_category("Status Properties")
@export var stun_time_modifier: float = 0.02

@export_category("Inventory")
@export var starting_item_slot_0:Item = null
@export var starting_item_slot_1:Item = null
@export var starting_item_slot_2:Item = null
@export var starting_item_slot_3:Item = null
@export var starting_item_slot_4:Item = null
@export var starting_item_slot_5:Item = null
@export var starting_item_slot_6:Item = null
@export var gas_tank_slot:GasTankItem = GasTankItem.new(1, 1000.0, 0, 0)

var inventory: Array[Item] = [null, null, null, null, null, null, null]
var hover_on_slot:int = 0
var currently_holding:Item
#Technically this makes it so the length is 7
var max_inv_hotbar_pos:int = 6 
#If we're using an item we don't want to be able to switch off of it, so we have this toggle here
var can_scroll_hotbar: bool = true
## Specifies if we have a tank connected for external air or not
var has_connected_tank:bool
## Specifies whether or not we deplete air from our lungs or the external tank
var drawing_from_mask:bool = false



var frame_timer = bhop_timing_frames

#Status Conditions

## Whether or not our head is submerged
var is_submerged = false
## Whether or not we are within an area of liquid
var in_liquid: bool = false
## Whether or not our legs are submerged
var is_wading: bool = false
## Whether or not we are currently in hitstun
var is_flinching: bool = false
## Whether or not we are considered swimming
var is_swimming: bool = false
## Whether or not we are considered alive
var is_alive: bool = true
var in_control: bool = true
var is_crouching:bool = false
var not_in_menu: bool = true
var is_drowning: bool = false

#Tracking Properties
var current_health: float
var current_air_supply: float
var can_call_air_subroutine: bool = true
var defaulting_location_title:String = "Ocean"
var corruption: float = 0
var can_deal_corrupt_damage: bool = true
var vel = Vector3()
var movement_mod = Vector3(1,1,1)
var movement = Vector2()
var movement_dir = Vector3()

var hands_in_anim = false
#Signal Bus
var signal_manager = VoidScreamers

func update_mouse_mode():
	if in_control and char_cam:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func misc_actions():
	if Input.is_action_just_pressed("toggle_light"):
		search_light.visible = !search_light.visible
	if Input.is_action_just_pressed("drop") and !changing_held_item:
		if inventory[hover_on_slot] != null:
			drop_item()

func drop_item():
		var dropped_scene = load(inventory[hover_on_slot].scene_link)
		var instance = dropped_scene.instantiate()
		instance.load_payload(inventory[hover_on_slot])
		instance.position = drop_local.global_position
		#instance.linear_velocity = player.glo
		get_node("/root/TestingChamber").add_child(instance)
		inventory[hover_on_slot] = null
		refresh_holding_2()

func mouse_look(event):
	if in_control and char_cam:
		if event is InputEventMouseMotion:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
			#print(rotation)
			pivot.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
			pivot.rotation = Vector3(clampf(pivot.rotation.x, -deg_to_rad(70), deg_to_rad(70)), 0, 0)

func get_wishdir():
	if not movement_enabled:
		return Vector3.ZERO
	if not in_control:
		return Vector3.ZERO
	return Vector3.ZERO + (transform.basis.z * Input.get_axis(move_forward, move_backward)) + (transform.basis.x * Input.get_axis(move_left, move_right))

func get_jump():
	return sqrt(4 * jump_force * gravity)

func get_gravity(delta):
	return gravity * delta

func accelerate(acc_dir, prev_vel, acc, max_vel, delta):
	var project_vel = prev_vel.dot(acc_dir)
	var acc_vel = clamp(max_vel - project_vel, 0, acc * delta)
	return prev_vel + acc_dir * acc_vel

func get_next_vel(prev_vel, delta):
	#print(vel.y)
	if vel.y < fall_damage_threshold and is_on_floor():
			
			print("got here")
			var fall_damage = (vel.y - fall_damage_threshold) * fall_damage_modifier
			fall_damage *= -1
			deal_damage(fall_damage)
	if is_submerged:
		return
	var grounded = is_on_floor()
	#print(grounded)
	var can_jump = grounded

	if grounded and (frame_timer >= bhop_timing_frames):
		var speed = prev_vel.length()
		if speed != 0:
			var drop = speed * friction * delta
			prev_vel *= max(speed - drop, 0) / speed
		else:
			if not additive_bhop:
				grounded = false
	var max_vel = 0
	var accel = 0
	
	if grounded:
		max_vel = max_ground_vel
		accel = ground_acc
		
		
	else:
		max_vel = max_air_vel
		accel = air_acc
	var velo = accelerate(get_wishdir(), prev_vel, accel, max_vel, delta)
	velo += Vector3.DOWN * get_gravity(delta)

	if(Input.is_action_pressed(jump) if jump_when_held else Input.is_action_just_pressed(jump) and movement_enabled and can_jump):
		velo.y = get_jump()
	vel = velo
	return velo;

func update_frame_timer():
	if is_on_floor() and !is_submerged:
		frame_timer += 1
	else:
		frame_timer = 0

func handle_movement(delta):
	update_frame_timer()
	var velo
	if is_submerged and !is_drowning:
		velo = get_swimming_vel()
	elif !is_submerged:
		velo = get_next_vel(velocity, delta)
	elif is_drowning:
		velocity = Vector3.ZERO
	velocity = velo

	move_and_slide()

var changing_held_item = false
var to_equip = null

func handle_hotbar_2():
	var prev_hover_on = hover_on_slot
	if Input.is_action_just_pressed(hotbar_up) and can_scroll_hotbar:
		if hover_on_slot >= max_inv_hotbar_pos:
			hud.highlight_hover_slot(max_inv_hotbar_pos, 0)
			hover_on_slot = 0
		else: 
			hud.highlight_hover_slot(hover_on_slot, hover_on_slot + 1)
			hover_on_slot += 1
	if Input.is_action_just_pressed(hotbar_down) and !changing_held_item:
		if hover_on_slot <= 0:
			hud.highlight_hover_slot(0, max_inv_hotbar_pos)
			hover_on_slot = max_inv_hotbar_pos
		else:
			hud.highlight_hover_slot(hover_on_slot, hover_on_slot - 1)
			hover_on_slot -= 1
	if prev_hover_on != hover_on_slot:
		handle_changing_2()
	else:
		if Input.is_action_pressed(left_click_use) and inventory[hover_on_slot] != null and changing_held_item != true:
			#can_scroll_hotbar = false
			inventory[hover_on_slot].use(self)
		if Input.is_action_pressed(right_click_use) and inventory[hover_on_slot] != null and changing_held_item != true:
			#can_scroll_hotbar = false
			inventory[hover_on_slot].secondary_use(self)

func handle_changing_2():
	if inventory[hover_on_slot] != null:	
		#if anim_manager.is_playing():
			#anim_manager.stop(false)
			#anim_manager.play(inventory[hover_on_slot].take_out_anim_name)
		anim_manager.stop(false)
		anim_manager.play(inventory[hover_on_slot].take_out_anim_name)
	currently_holding = inventory[hover_on_slot]
		

func handle_changing():
	if changing_held_item:
		#print("got here")
		print(currently_holding)
		if currently_holding != null:
			currently_holding.put_away(self)
			currently_holding = null
		if inventory[hover_on_slot] != null:
			print("taking out")
			currently_holding = inventory[hover_on_slot]
			hud.change_inv_hb_text(currently_holding.hover_name)
			currently_holding.take_out(self)
		else:
			currently_holding = null
			changing_held_item = false


func handle_hotbar():
	var prev_hover_on_slot = hover_on_slot
	#Scrolling down should move the highlighted slot updwards (ie. to the right)
	if Input.is_action_just_pressed(hotbar_up) and !changing_held_item:
		changing_held_item = true
		if hover_on_slot >= max_inv_hotbar_pos:
			hud.highlight_hover_slot(max_inv_hotbar_pos, 0)
			hover_on_slot = 0
		else: 
			hud.highlight_hover_slot(hover_on_slot, hover_on_slot + 1)
			hover_on_slot += 1
	#Scrolling up should move the highlighted slot downwards (ie. to the left)
	if Input.is_action_just_pressed(hotbar_down) and !changing_held_item:
		changing_held_item = true
		if hover_on_slot <= 0:
			hud.highlight_hover_slot(0, max_inv_hotbar_pos)
			hover_on_slot = max_inv_hotbar_pos
		else:
			hud.highlight_hover_slot(hover_on_slot, hover_on_slot - 1)
			hover_on_slot -= 1
			
	if prev_hover_on_slot != hover_on_slot:
		print("Switched to: {0}".format([hover_on_slot]))
		if inventory[prev_hover_on_slot] == null and inventory[hover_on_slot] == null:
			changing_held_item = false
	if Input.is_action_pressed(left_click_use) and inventory[hover_on_slot] != null and changing_held_item != true:
		inventory[hover_on_slot].use(self)
	if Input.is_action_pressed(right_click_use) and inventory[hover_on_slot] != null and changing_held_item != true:
		inventory[hover_on_slot].secondary_use(self)
	handle_changing()

func refresh_holding():
	if currently_holding == null and inventory[hover_on_slot] != null:
		currently_holding = inventory[hover_on_slot]
		currently_holding.take_out(self)
	elif currently_holding != null and inventory[hover_on_slot] == null:
		currently_holding = null
		hud.change_inv_hb_text("")
		hud.add_item_slot_texture(-13,hover_on_slot)

func refresh_holding_2():
	#This happens when we pick something up
	if currently_holding == null and inventory[hover_on_slot] != null:
		handle_changing_2()
		hud.change_inv_hb_text(currently_holding.hover_name)
	#This happens when we drop something
	elif currently_holding != null and inventory[hover_on_slot] == null: 
		currently_holding = null
		hud.change_inv_hb_text("")
		hud.remove_item_sprite_from_hotbar(hover_on_slot)


func draw_debug():
	if not enable_debug:
		return
	var debug_vel = velocity
	debug_vel.y = 0
	print("MovementController | Bhop | Vel: ", debug_vel.length())
	if debug_vel_raycast:
		debug_vel_raycast.target_position = debug_vel
	if debug_wishdir_raycast:
		debug_wishdir_raycast.target_position = get_wishdir()

func  _physics_process(delta):
	check_statuses()
	update_stats()
	if is_alive and !is_drowning and !is_flinching:
		handle_movement(delta)
		handle_hotbar_2()
		misc_actions()
	draw_debug()

func _unhandled_input(event):
	mouse_look(event)

func _ready():
	char_cam.make_current()
	current_health = initial_max_health
	current_air_supply = base_air_supply

	signal_manager.connect("region_entered", region_update)
	signal_manager.connect("region_exited", left_region)

	#Set slots in array to items
	inventory[0] = starting_item_slot_0
	inventory[1] = starting_item_slot_1
	inventory[2] = starting_item_slot_2
	inventory[3] = starting_item_slot_3
	inventory[4] = starting_item_slot_4
	inventory[5] = starting_item_slot_5
	inventory[6] = starting_item_slot_6
	currently_holding = inventory[0]
	hud.highlight_hover_slot(0,0)

	print_debug("Player Ready")

	if play_startup_anim:
		anim_manager.play("start_up")
		start_up_coroutine()
	else:
		in_control = true;
	update_mouse_mode()

func get_swimming_vel():
	var swim_vec = Vector3(0,0,0)
	#Coordinate movement is based on mouse position, rather than standard horizontal locked movement

	#var swim_movement = Input.get_vector("left", "right", "forwards", "backwards")
		
	if Input.is_action_pressed(move_forward):
		swim_vec += -char_cam.global_transform.basis.z
	if Input.is_action_pressed(move_backward):
		swim_vec += char_cam.global_transform.basis.z
	if Input.is_action_pressed(move_left):
		swim_vec += -global_transform.basis.x
	if Input.is_action_pressed(move_right):
		swim_vec += global_transform.basis.x
	
	#if Input.is_action_just_pressed("jump") && can_boost:
		#movement_mod *= boost_multiplier
		#can_boost = false
		#boost_swimming_coroutine()
		#print_debug("Boosting")
	if Input.is_action_pressed("crouch"):
		movement_mod *= Vector3(0.2, forced_sink_multiplier, 0.2)  
		swim_vec += -Vector3(0,1,0)
	if Input.is_action_pressed(jump):
		movement_mod *= Vector3(0.2, forced_sink_multiplier, 0.2)
		swim_vec += Vector3(0,1,0)
		

	#movement_dir = (transform.basis * Vector3(swim_movement.x, swim_vec.y, swim_movement.y).normalized())
	movement_dir = (Vector3(swim_vec.x, swim_vec.y, swim_vec.z).normalized())
	#print("move-dir:")
	#print(movement_dir)
	if movement_dir and !is_flinching:
		vel = movement_dir * base_swim_speed * movement_mod
		
		# vel.x = clampf(vel.x, -8, 8)
		if vel.y < -10:
			vel.y = -10
		if vel.y > 20:
			vel.y = 20
		# vel.z = clampf(vel.z, -8, 8)
		draw_air_amount_modifier = 1.3
	else:
		vel.x = move_toward(vel.x, 0, base_swim_speed / underwater_friction)
		vel.y = move_toward(vel.y, 0, base_swim_speed / underwater_friction)
		vel.z = move_toward(vel.z, 0, base_swim_speed / underwater_friction)
		draw_air_amount_modifier = 1
	return vel

func check_statuses():
	#if in_control:
	var depth = $LiquidNotifier.get_depth()

	if current_health <= 0:
		die()
		return
	else:
		if corruption >= 100.0:
			if can_deal_corrupt_damage:
				deal_passive_damage(corruption_damage)
				can_deal_corrupt_damage = false
				corruption_damage_coroutine()

		if in_liquid:
			if current_air_supply <= 0.0:
				is_drowning = true
				#Going to need to start some coroutine here
				#probably return from here
			if depth <= 2.0 and depth > 1.5:
				#We must be submerged
				is_submerged = true
				hud.air_bar.visible = true;
				underwater_overlay.visible = true;
			elif depth >= 1.0 and depth <= 1.5:
				is_wading = true
			else:
				underwater_overlay.visible = false
				is_submerged = false
				is_wading = false
		

		elif not in_liquid:
			if depth != 2.0:
				
				is_submerged = false
				hud.air_bar.visible = false;
				underwater_overlay.visible = false
				#print_debug("Submerge Toggle")

func update_stats():
	if is_submerged and can_call_air_subroutine and !is_drowning:
		print("got here")
		can_call_air_subroutine = false
		draw_from_air_supply_coroutine()

func _unhandled_key_input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func die():
	is_alive = false;
	in_control = false;
	#Probably should start some sort of animation here, before destroying the player object.
	#For now, probably just make it quit

func deal_passive_damage(damage: float):
	current_health -= damage
	if current_health <= 0.0:
		die()
	#perhaps play a sound here?
	#No flinching, unlike contact damage

func deal_damage(damage:float):
	if damage <= 0:
		print("Healing does not go here")
		return
	else:
		damage_overlay.visible = true
		if(is_flinching):
			current_health -= damage
			print(damage)
			print(current_health)
			if(current_health <= 0):
				die()
			damage_overlay.visible = false
			return #Don't want stacking flinches
		else:
			current_health -= damage
			print(damage)
			print(current_health)
			if(current_health <= 0):
				die()
			is_flinching = true
			damage_flinch_coroutine(damage)



func corruption_damage_coroutine():
	await get_tree().create_timer(corruption_wait_time).timeout
	can_deal_corrupt_damage = true

func damage_flinch_coroutine(damage):
	await get_tree().create_timer(damage * stun_time_modifier).timeout
	damage_overlay.visible = false
	is_flinching = false

func draw_from_air_supply_coroutine():
	
	print("breathing")
	print(hud.air_bar.value)
	await get_tree().create_timer(draw_air_interval * draw_air_interval_modifier).timeout
	#Check if we're still submerged, and if true, breath
	if is_submerged:
		current_air_supply -= draw_air_amount * draw_air_amount_modifier;
	can_call_air_subroutine = true

func update_hud():
	if hud.info_box.visible:
		hud.x_coord_stats.text = "{0}".format([global_position.x])
		hud.z_coord_stats.text = "{0}".format([global_position.z])
		hud.depth_stats.text = "{0}".format([global_position.y])
	hud.air_bar.value = current_air_supply
	

#func check_zone():
func start_up_coroutine():
	await anim_manager.animation_finished
	in_control = true

func region_update(title: String, region_type: bool):
	print("update")
	if region_type:
		hud.v_region_title.text = title
	else:
		hud.h_region_title.text = title

func left_region(region_type:bool):
	print("update")
	if region_type:
		hud.v_region_title.text = defaulting_location_title
	else:
		hud.h_region_title.text = defaulting_location_title
