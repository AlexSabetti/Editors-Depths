class_name PlayerController
extends CharacterBody3D

@export_group("Speed Properties")
@export var base_speed: float = 1.5
@export var run_speed_mod: float = 1
@export var crouch_speed_mod: float = 0.5
@export_group("Mouse Properties")
@export var mouse_sens: float = 0.003
@export_group("Jumping Properties")
@export var jump_speed: float = 4
@export var personal_grav: float = 16.8
@export_group("Swimming Properties")
@export var base_swim_speed: float = 1.2
@export var swim_speed_decay: float = 0.02
@export var swim_to_air_launch_speed: float = 1.5
@export var wading_speed: float = 0.8
@export var boost_downtime: float = 1.0
@export var boost_multiplier: float = 1.2
@export var underwater_friction: float = 80.0
@export var forced_sink_multiplier: float = 10.0
@export_group("Health Properties")
@export var initial_max_health: float = 100.0
@export var corruption_damage: float = 5.0
@export var corruption_wait_time: float = 2.0
@export var fall_damage_threshold: float = -25
@export var fall_damage_modifier: float = 0.58
@export_group("Air_Properties")
@export var base_air_supply: float = 100.0
@export var draw_air_interval: float = 5.0
@export var draw_air_interval_modifier: float = 1
@export var draw_air_amount: float = 1.0
@export var draw_air_amount_modifier: float = 1
@export_group("Startup Settings")
@export var play_startup_anim: bool = true
@export_group("Status Properties")
@export var stun_time_modifier: float = 0.02

var current_health: float
var current_air_supply: float
var base_with_reserve_air_supply: float
var can_call_air_subroutine: bool = true

var is_swimming: bool = false
var is_running: bool = false
var is_alive: bool = true
var not_in_menu: bool = true
var is_drowning: bool = false
var in_control: bool = false
var is_crouching: bool = false
var is_jumping: bool = false
var is_still_in_motion = false
var is_submerged = false
var in_liquid: bool = false
var is_wading: bool = false
var is_flinching: bool = false

var corruption: float = 0
var can_deal_corrupt_damage: bool = true

var can_boost: bool = true

@onready var pivot = get_node("Pivot")
@onready var char_cam: Camera3D = get_node("Pivot/Eyes")
@onready var hud: HUDController = get_node("Pivot/Eyes/HUD")
@onready var anim_manager: AnimationPlayer = get_node("AnimationPlayer")
@onready var underwater_overlay: MeshInstance3D = get_node("Pivot/Eyes/LiquidOverlay")
@onready var damage_overlay: MeshInstance3D = get_node("Pivot/Eyes/DamageOverlay")

var defaulting_location_title:String = "Ocean"

#vector variables
var vel = Vector3()
var movement_mod = Vector3(1,1,1)
var movement = Vector2()
var movement_dir = Vector3()

var signal_manager = VoidScreamers
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	char_cam.make_current()
	current_health = initial_max_health
	current_air_supply = base_air_supply

	signal_manager.connect("region_entered", region_update)
	signal_manager.connect("region_exited", left_region)
	print_debug("Player Ready")
	if play_startup_anim:
		anim_manager.play("start_up")
		start_up_coroutine()
	else:
		in_control = true;

func control(delta) -> void:
	if in_control:
		movement_mod = Vector3(1,1,1)
		if not_in_menu and is_alive:
			#movement = Input.get_vector("left", "right", "forward", "backwards")
			#print(is_submerged)
			if is_submerged and !is_drowning:
				var swim_vec = Vector3(0,0,0)
				#Coordinate movement is based on mouse position, rather than standard horizontal locked movement

				#var swim_movement = Input.get_vector("left", "right", "forwards", "backwards")
				 
				if Input.is_action_pressed("forwards"):
					swim_vec += -char_cam.global_transform.basis.z
				if Input.is_action_pressed("backwards"):
					swim_vec += char_cam.global_transform.basis.z
				if Input.is_action_pressed("left"):
					swim_vec += -global_transform.basis.x
				if Input.is_action_pressed("right"):
					swim_vec += global_transform.basis.x
				
				#if Input.is_action_just_pressed("jump") && can_boost:
					#movement_mod *= boost_multiplier
					#can_boost = false
					#boost_swimming_coroutine()
					#print_debug("Boosting")
				if Input.is_action_pressed("crouch"):
					movement_mod *= Vector3(0.2, forced_sink_multiplier, 0.2)  
					swim_vec += -Vector3(0,1,0)
				if Input.is_action_pressed("jump"):
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

				#Perhaps jumping gives a quick boost of speed while Underwater?
			elif is_submerged and is_drowning:
				in_control = false
				return
			elif !is_submerged and is_drowning:
				#Perhaps make an animation play out where the player is coughing up liquid
				pass
			else:
				if not is_on_floor():
					vel.y -= personal_grav * delta
					print(vel.y)
				else:
					if vel.y < fall_damage_threshold:
						print("got here")
						var fall_damage = (vel.y - fall_damage_threshold) * fall_damage_modifier
						fall_damage *= -1
						deal_damage(fall_damage)
					vel.y=0
				movement = Input.get_vector("left", "right", "forwards", "backwards")
				movement_dir = (transform.basis * Vector3(movement.x, 0, movement.y).normalized())
				if is_wading:  
					movement_mod *= wading_speed
				if is_on_floor() and Input.is_action_just_pressed("jump") and !is_flinching:
					vel.y = jump_speed
				if movement_dir and !is_flinching:
					if is_on_floor():
						#print_debug(global_position)
						vel.x = movement_dir.x * base_speed * movement_mod.x
						vel.z = movement_dir.z * base_speed * movement_mod.z
						#print_debug(vel)
					else: 
						vel.x += movement_dir.x * base_speed * movement_mod.x * 0.01
						vel.z += movement_dir.z * base_speed * movement_mod.z * 0.01
						vel.x = clampf(vel.x, -(base_speed), (base_speed))
						vel.z = clampf(vel.z, -(base_speed), (base_speed))
					
				else:
					if is_on_floor():
						vel.x = move_toward(vel.x, 0, base_speed / 2)
						vel.z = move_toward(vel.z, 0, base_speed / 2)
					else:
						vel.x = move_toward(vel.x, 0, base_speed / 90)
						vel.z = move_toward(vel.z, 0, base_speed / 90)
			velocity = vel
			move_and_slide()


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
			#Damage is dealt too fast, need to add a timer which allows it to be more reasonable
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

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var move_pass = event as InputEventMouseMotion
		camera_rotate(move_pass.relative * mouse_sens)
		
func camera_rotate(move: Vector2):
	if in_control:
		#print_debug(move)
		rotate_y( - move.x)
		#print(rotation)
		pivot.rotate_x( - move.y)
		pivot.rotation = Vector3(clampf(pivot.rotation.x, -deg_to_rad(70), deg_to_rad(70)), 0, 0)

func _unhandled_key_input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _physics_process(delta):
	check_statuses()
	update_stats()
	control(delta)
	update_hud()
	handle_input()

func handle_input():
	if Input.is_action_just_pressed("hud_toggle_depth_info"):
		hud.info_box.visible = !hud.info_box.visible
		print_debug(hud.info_box.visible)
	
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

func boost_swimming_coroutine():
	await get_tree().create_timer(boost_downtime).timeout
	can_boost = true

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