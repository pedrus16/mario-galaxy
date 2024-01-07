extends CharacterBody2D

class_name Player

const WALK_SPEED := 250.0
const JUMP_VELOCITY := 400.0

var planets = []
var current_planet = null
var points = []

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
	
func _draw():
	if points.size() >= 2:
		draw_polyline(points, Color(1, 0, 0, 1))
	
func _process(_delta):
	# Trajectory computation
	# TODO Implement Runge-Kutta method for better precision https://en.wikipedia.org/wiki/Runge%E2%80%93Kutta_methods
	var _position = Vector2()
	var _vel = get_real_velocity()
	points = [_position]
	var hit = false
	for i in 200:
		var _gravity = Vector2()
		for planet in planets:
			_gravity += planet.get_gravity_at(global_position + _position)
			if (global_position + _position).distance_to(planet.global_position) <= planet.radius * 100:
				hit = true
		if hit:
			break
		_vel += _gravity * 1/8
		_position += _vel * 1/8
		points.push_front(_position)
	queue_redraw()

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
	if input.jumping:
		velocity += up_direction * JUMP_VELOCITY
	
	# Reset jump state.
	input.jumping = false
	
	move_and_slide()
		
	$PlayerSprite.rotation = up_direction.angle() + PI / 2
	camera.rotation = up_direction.angle() + PI / 2
	$Collision.rotation = up_direction.angle() + PI / 2
	
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("zoom_out") and camera.zoom.x > (1.0 / 128.0):
			camera.zoom *= 0.5
		if Input.is_action_just_pressed("zoom_in") and camera.zoom.x < 1:
			camera.zoom *= 2
		
	# Push rigid bodies away
	var push_force = 80.0
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)

