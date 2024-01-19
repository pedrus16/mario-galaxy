extends CharacterBody2D

class_name Player

const WALK_SPEED := 512.0
const JUMP_VELOCITY := 512.0

var planets = []
var current_planet = null
var in_vehicle := false

# Set by the authority, synchronized on spawn.
@export var player := 1 :
	set(id):
		player = id
		# Give authority over the player input to the appropriate peer.
		$PlayerInput.set_multiplayer_authority(id)
		
# Player synchronized input.
@onready var input = $PlayerInput

@onready var camera := $Camera2D

func _ready():
	# Set the camera as current if we are this player.
	if player == multiplayer.get_unique_id():
		camera.make_current()
	planets = get_tree().get_nodes_in_group("planet")
	
func _input(event):
	if event.is_action_pressed("zoom_out") and camera.zoom.x > (1.0 / 2048.0):
		camera.zoom *= 0.5
	if event.is_action_pressed("zoom_in") and camera.zoom.x < 0.5:
		camera.zoom *= 2	
	
func _process(_delta):
	if input.interacting:
		input.interacting = false
		$InteractionArea.try_interacting(self)
		
	if is_on_floor() and input.direction:
		$PlayerSprite.play("walk")
	elif not is_on_floor():
		$PlayerSprite.play("jump")
	else:
		$PlayerSprite.play("idle")
	
	if is_on_floor() and input.direction != 0:
		$PlayerSprite.flip_h = input.direction < 0
		

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
		
	$PlayerSprite.rotation = up_direction.angle() + PI / 2
	camera.rotation = up_direction.angle() + PI / 2
	$Collision.rotation = up_direction.angle() + PI / 2
	
	# Push rigid bodies away
	var push_force = 80.0
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
