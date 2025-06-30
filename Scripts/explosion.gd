class_name explosion
extends AreaDamage

@export_subgroup("Radius")
@export var starting_explosion_radius: float
@export var final_explosion_radius: float

@export_subgroup("Scaling")
@export var scaling_speed: float
@export var scale_by: float

@export_subgroup("Knockback")
@export var knockback_force: float
@export var knockback_direction: Vector3
# For a damage-based knockback version
@export var dmg_kb_mult: float
@export var knockback_dir_override: bool = false
@export var knockback_force_override: bool = false

@export_subgroup("Triggering")
@export var hits_multiple_times: bool = false
@export var max_trigger_on_same_body: int = 1
@export var retriggered_damage_decay_ratio: float
@export var targeted: bool = false

@onready var collider: CollisionShape3D = $CollisionShape3D

@onready var debug_mesh: MeshInstance3D = $Debug_Area #Must always be named this

var do_debug: bool = false

var pending_activation: bool = true
var pending_activation_bodies: Array[entity] = []

var current_radius: float = 0.0
func _ready():
	connect("body_entered", _on_body_entered)

func read_payload(payload: Dictionary):
	if "starting_explosion_radius" in payload:
		starting_explosion_radius = payload["starting_explosion_radius"]
	if "final_explosion_radius" in payload:
		final_explosion_radius = payload["final_explosion_radius"]
		print(final_explosion_radius)
	if "scaling_speed" in payload:
		scaling_speed = payload["scaling_speed"]
	if "scale_by" in payload:
		scale_by = payload["scale_by"]
	if "knockback_force" in payload:
		knockback_force = payload["knockback_force"]
	if "knockback_direction" in payload:
		knockback_direction = payload["knockback_direction"]
	if "knockback_dir_override" in payload:
		knockback_dir_override = payload["knockback_dir_override"]
	if "knockback_force_override" in payload:
		knockback_force_override = payload["knockback_force_override"]
	if "hits_multiple_times" in payload:
		hits_multiple_times = payload["hits_multiple_times"]
	if "max_trigger_on_same_body" in payload:
		max_trigger_on_same_body = payload["max_trigger_on_same_body"]
	if "retriggered_damage_decay_ratio" in payload:
		retriggered_damage_decay_ratio = payload["retriggered_damage_decay_ratio"]
	if "targeted" in payload:
		targeted = payload["targeted"]
	if "damage" in payload:
		damage = payload["damage"]
	if "dmg_kb_mult" in payload:
		dmg_kb_mult = payload["dmg_kb_mult"]
	if "debug" in payload:
		do_debug = true
	# Everything has been read
	print("finished explosion setup")
	pending_activation = false
	

func _physics_process(delta: float):
	if pending_activation:
		print("waiting")
		return
	# The following is a bad idea, I'll probably use threading for this?
	if pending_activation_bodies.size() > 0:
		print(pending_activation_bodies)
	while pending_activation_bodies.size() > 0:
		hit_check(pending_activation_bodies.pop_front(), 1)
	
	if current_radius < final_explosion_radius:
		current_radius += scale_by * delta * scaling_speed
		if current_radius >= final_explosion_radius:
			print("Explosion reached final radius")
			current_radius = final_explosion_radius
			queue_free()
			# Explosion ends here
	
			#print("Explosion radius: ", current_radius)
	collider.shape.radius = current_radius
	
func _process(_delta):
	if do_debug:
		debug_mesh.visible = true
		debug_mesh.scale = Vector3.ONE * current_radius
	else:
		debug_mesh.visible = false

	

func _update_collision_shape():
		collider.shape.radius = current_radius

func _on_body_entered(body):
	print(typeof(body))
	if body is CharacterBody3D:
		print("Caught ", body, " in explosion")
		pending_activation_bodies.append(body)

func hit_check(body, hit_num):
	var explosion_origin = global_position
	var body_origin = body.global_position
	var dir = (body_origin - explosion_origin).normalized()

	var space_state = get_world_3d().direct_space_state
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(explosion_origin, body_origin)
	query.exclude = [self]
	query.collision_mask = 0b1111
	
	
	var result: Dictionary = space_state.intersect_ray(query)

	var has_los = false
	print("result: ", result)
	if result.get("collider") == body:
		has_los = true
	else:
		print("No line of sight to body: ", body, " from explosion origin: ", explosion_origin, " to body origin: ", body_origin)
		return
	
	if has_los:
		var actual_damage: float = damage * (1 /(distance_from(body_origin, explosion_origin) + 1))
		if body.has_method("deal_damage"):
			body.deal_damage(actual_damage)
		if body.has_method("apply_knockback"):
			if knockback_dir_override == true and knockback_force_override == true:
				body.apply_knockback(knockback_direction, knockback_force)
			elif knockback_dir_override == true:
				body.apply_knockback(knockback_direction,  actual_damage * dmg_kb_mult)
			elif knockback_force_override:
				body.apply_knockback(dir, knockback_force)
			else:
				body.apply_knockback(dir, actual_damage * dmg_kb_mult)



func distance_from(A, B) -> float:
	return sqrt(pow((A.x - B.x), 2) + pow(A.y - B.y, 2) + pow(A.z - B.z, 2))
