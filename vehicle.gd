extends Node2D

class_name Vehicle

var player: Player = null
var player_parent = null

var planets = []
var points = []

func _ready():
	planets = get_tree().get_nodes_in_group("planet")

func _draw():
	if points.size() >= 2:
		draw_polyline(points, Color(1, 0, 0, 1))
	
func _process(delta):
	# Trajectory computation
	# TODO Refactor into a separate script (code also present in player.gd)
	# TODO Implement Runge-Kutta method for better precision https://en.wikipedia.org/wiki/Runge%E2%80%93Kutta_methods
	var _position = Vector2()
	var _vel = $RigidBody2D.linear_velocity
	points = [$RigidBody2D.position + _position]
	var hit = false
	for i in 200:
		var _gravity = Vector2()
		for planet in planets:
			_gravity += planet.get_gravity_at($RigidBody2D.global_position + _position)
			if ($RigidBody2D.global_position + _position).distance_to(planet.global_position) <= planet.radius * 100:
				hit = true
		if hit:
			break
		_vel += _gravity * 1/8
		_position += _vel * 1/8
		points.push_front($RigidBody2D.position + _position)
	queue_redraw()

func _physics_process(delta):
	if not player:
		return
	
	# Keep the player position on the ship
	player.global_position = $RigidBody2D.global_position
	player.global_rotation = $RigidBody2D.global_rotation
	
	# Ship controls
	if player.input.vehicle_direction.is_zero_approx():
		return
		
	var main_force = 1500000
	var main_thrust = Vector2(0, player.input.vehicle_direction.y) * main_force
	$RigidBody2D.apply_central_force(main_thrust.rotated($RigidBody2D.rotation))
	var side_force = 50000000
	$RigidBody2D.apply_torque(player.input.vehicle_direction.x * side_force)

func enter(_player: Player):
	if player:
		return

	player = _player
	player_parent = player.get_parent()
	player.set_physics_process(false)
	player.position = Vector2()
	player.rotation = 0
	player.camera.rotation = 0
	player.visible = false
	player.in_vehicle = true

func exit():
	if not player:
		return
		
	player.set_physics_process(true)
	player.position = $RigidBody2D.global_position
	player.rotation = 0
	player.visible = true
	player.velocity = $RigidBody2D.linear_velocity
	player.move_and_slide()
	player.in_vehicle = false
	player = null
	
	
func _on_entry_area_player_interacted(interacting_player: Player):
	if player && interacting_player == player:
		exit()
	elif not interacting_player.in_vehicle:
		enter(interacting_player)


