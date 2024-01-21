extends CharacterBody2D

class_name Player

const WALK_SPEED := 512.0
const JUMP_VELOCITY := 512.0
const AIR_BREAK := 32.0 # Rate to break speed mid air
const AIR_CONTROL := 128.0 # Max velocity allowed to be added via direction

var planets = []

# Planet currently affecting the player's up_direction
var current_planet: Planet = null

# Is player in a vehicle
var in_vehicle := false

# Picked up item
var item: RigidBody2D = null

var zoom := 0.25

var initial_jump_velocity := Vector2()

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
	
	# Vector representing the tangent line to the planet's surface
	var right_direction = up_direction.rotated(PI / 2)
		
	# Walk
	var move_dir = right_direction * input.direction
	if is_on_floor():
		velocity = move_dir * WALK_SPEED
	elif input.direction != 0:
		# In-air control
		var horizontal_velocity = velocity.dot(right_direction.normalized())
		if abs(horizontal_velocity + input.direction * AIR_BREAK) < abs(horizontal_velocity):
			var diff = min(AIR_BREAK, abs(horizontal_velocity) - abs(input.direction * AIR_BREAK))
			velocity += move_dir * diff
		elif abs(horizontal_velocity + input.direction * AIR_BREAK) < AIR_CONTROL:
			velocity += move_dir * AIR_BREAK
	
	# Jump
	if input.jumping && is_on_floor():
		velocity += up_direction * JUMP_VELOCITY
		initial_jump_velocity = velocity

	move_and_slide()
	
	if not input.jumping:
		apply_floor_snap()
		
	# Reset jump state.
	input.jumping = false
		
	$Node2D.rotation = right_direction.angle()
	
	# Push rigid bodies away
	var push_force = 80.0
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		var collider = c.get_collider()
		if collider is RigidBody2D:
			collider.apply_central_impulse(-c.get_normal() * push_force)
			
	if item:
		item.global_position = $Node2D/PickupPoint.global_position
		item.rotation = right_direction.angle()
		
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
