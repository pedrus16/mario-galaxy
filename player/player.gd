extends CharacterBody2D

class_name Player

const WALK_SPEED := 512.0
const JUMP_VELOCITY := 512.0

var planets = []

# Planet currently affecting the player's up_direction
var current_planet: Planet = null

# Is player in a vehicle
var in_vehicle := false

# Picked up item
var item: RigidBody2D = null

var zoom := 0.25

# Set by the authority, synchronized on spawn.
@export var player := 1 :
	set(id):
		player = id
		# Give authority over the player input to the appropriate peer.
		$PlayerInput.set_multiplayer_authority(id)
		
# Player synchronized input.
@onready var input = $PlayerInput

@onready var camera := $Node2D/Camera2D

func _ready():
	# Set the camera as current if we are this player.
	if player == multiplayer.get_unique_id():
		camera.make_current()
	planets = get_tree().get_nodes_in_group("planet")
	
func _input(event):
	if event.is_action_pressed("zoom_out") and zoom > (1.0 / 2048.0):
		zoom *= 0.5
		var tween = get_tree().create_tween()
		tween.tween_property(camera, "zoom", Vector2(zoom, zoom), 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	if event.is_action_pressed("zoom_in") and zoom < 0.5:
		zoom *= 2
		var tween = get_tree().create_tween()
		tween.tween_property(camera, "zoom", Vector2(zoom, zoom), 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
func _process(_delta):
	if input.interacting:
		input.interacting = false
		if item:
			drop_item()
		else:
			if not $Node2D/InteractionArea.try_interacting(self):
				$Node2D/PickupArea.try_pickup()
		
	if is_on_floor() and input.direction:
		$Node2D/PlayerSprite.play("walk")
	elif not is_on_floor():
		$Node2D/PlayerSprite.play("jump")
	else:
		$Node2D/PlayerSprite.play("idle")
	
	if is_on_floor() and input.direction != 0:
		$Node2D/PlayerSprite.flip_h = input.direction < 0
		$Node2D/PickupArea.scale.x = -1 if input.direction < 0 else 1
		

func get_combined_gravity():
	var gravity = Vector2()
	for planet in planets:
		gravity += planet.get_gravity_at(global_position)
		
	return gravity

func _physics_process(delta):
	# Gravity
	var gravity = get_combined_gravity()
	if not is_on_floor():
		velocity = get_real_velocity()
		velocity += gravity * delta
	
	# Align player orientation when entering planet's area of influence
	if current_planet:
		var down_direction = global_position.direction_to(current_planet.get_gravity_center()).normalized()
		if not down_direction.is_zero_approx():
			up_direction = -down_direction
		
	# Walk
	if is_on_floor():
		var move_dir = up_direction.rotated(PI / 2) * input.direction
		velocity = move_dir * WALK_SPEED
		
	# Jump
	if input.jumping && is_on_floor():
		velocity += up_direction * JUMP_VELOCITY
	
	move_and_slide()
	
	if not input.jumping:
		apply_floor_snap()
		
	# Reset jump state.
	input.jumping = false
		
	$Node2D.rotation = up_direction.angle() + PI / 2
	
	# Push rigid bodies away
	var push_force = 80.0
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		var collider = c.get_collider()
		if collider is RigidBody2D:
			collider.apply_central_impulse(-c.get_normal() * push_force)
			
	if item:
		item.global_position = $Node2D/PickupPoint.global_position
		item.rotation = up_direction.angle() + PI / 2
		
func drop_item():
	item.freeze = false
	var _angle = PI / 4 if $Node2D/PickupArea.scale.x > 0 else -PI / 4 
	item.apply_central_impulse(get_real_velocity() + up_direction.rotated(_angle) * item.mass * 400)
	item.collision_layer = 0b00100000
	item = null

func _on_pickup_area_body_picked_up(body: RigidBody2D):
	item = body
	item.freeze = true
	item.collision_layer = 0b00010000
	var tween = get_tree().create_tween()
	tween.tween_property(item, "global_position", $Node2D/PickupPoint.global_position, 0.2).set_trans(Tween.TRANS_SPRING)
	tween.parallel().tween_property(item, "rotation", up_direction.angle() + PI / 2, 0.2).set_trans(Tween.TRANS_SPRING)
