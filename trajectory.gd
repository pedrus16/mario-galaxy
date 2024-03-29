extends Node2D

class_name Trajectory

@export_node_path("RigidBody2D", "CharacterBody2D") var body_path
var rigid_body: RigidBody2D
var character_body: CharacterBody2D
var planets = []
var points = []

@export var step := 1.0
@export var paused := false


func _ready():
	planets = get_tree().get_nodes_in_group("planet")
	if body_path:
		var body = get_node(body_path)
		if body is RigidBody2D:
			rigid_body = body
		if body is CharacterBody2D:
			character_body = body
	
func _draw():
	if points.size() >= 2:
		draw_polyline(points, Color(1, 0, 0, 1))
		
func compute_velocity(position: Vector2, velocity: Vector2, step := step) -> Vector2:
	return velocity + get_combined_gravity_at(position) * step	
		
func get_combined_gravity_at(point: Vector2) -> Vector2:
	var gravity = Vector2()
	for planet in planets:
			gravity += planet.get_gravity_at(point)
	
	return gravity
		
func compute_rigid_body_trajectory(count := 200) -> Array[Vector2]:
	var _position = Vector2()
	var _vel = rigid_body.linear_velocity
	var _points: Array[Vector2] = [rigid_body.position + _position]
	var hit = false
	for i in count:
		var _origin = rigid_body.global_position + rigid_body.center_of_mass + _position
		var distance = 0
		_vel += get_combined_gravity_at(_origin) * step
		_position += _vel * step
		for planet in planets:
			distance = (rigid_body.global_position + rigid_body.center_of_mass + _position).distance_to(planet.global_position)
			if distance <= planet.radius * 100:
				hit = true
		if hit:
			break
		_points.push_front(rigid_body.position + _position)
	
	return _points
	
func compute_character_body_trajectory(count := 200) -> Array[Vector2]:
	var _position = Vector2()
	var _vel = character_body.get_real_velocity()
	var _points: Array[Vector2] = [_position]
	var hit = false
	for i in count:
		var _origin = character_body.global_position + _position
		_vel += get_combined_gravity_at(_origin) * step
		_position += _vel * step
		for planet in planets:
			if (character_body.global_position + _position).distance_to(planet.global_position) <= planet.radius * 100:
				hit = true
		if hit:
			break
		_points.push_front(_position)
	
	return _points

func _physics_process(delta):
	if rigid_body:
		points = compute_rigid_body_trajectory()
		queue_redraw()
	elif character_body:
		points = compute_character_body_trajectory()
		queue_redraw()
		
