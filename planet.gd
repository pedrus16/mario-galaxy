@tool
extends Node2D
class_name Planet

## Radius of the planet body in meters.
@export_range(1, 10000) var radius := 5.0:
	set(new_radius):
		radius = new_radius
		if not is_inside_tree():
			return
		$GravityArea.set_gravity_point_unit_distance(new_radius * 100)
		$GravityArea/Collision.shape.set_radius(new_radius * 100 * gravity)
		$Body/Collision.shape.set_radius(new_radius * 100)
	get:
		return radius
		
## Gravity at the surface in m/s²
@export_range(0, 10000) var gravity := 9.8:
	set(new_gravity):
		gravity = new_gravity
		if not is_inside_tree():
			return
		$GravityArea.set_gravity(new_gravity * 100)
	get:
		return gravity
		
## Height from surface in meters that will influence player's up direction
@export_range(0, 10000) var influence_height := 5.0:
	set(new_height):
		influence_height = new_height
		if not is_inside_tree():
			return
		$InfluenceArea/CollisionShape2D.shape.set_radius(radius * 100 + influence_height * 100)
	get:
		return influence_height
		
func _refresh_children_proprerties():
	$GravityArea.set_gravity_point_unit_distance(radius * 100)
	$GravityArea/Collision.shape.set_radius(radius * 100 * gravity)
	$Body/Collision.shape.set_radius(radius * 100)
	$GravityArea.set_gravity(gravity * 100)
	$InfluenceArea/CollisionShape2D.shape.set_radius(radius * 100 + influence_height * 100)

# Called when the node enters the scene tree for the first time.
func _ready():
	if not $GravityArea/Collision.shape:
		$GravityArea/Collision.shape = CircleShape2D.new()
	if not $Body/Collision.shape:
		$Body/Collision.shape = CircleShape2D.new()
	if not $InfluenceArea/CollisionShape2D.shape:
		$InfluenceArea/CollisionShape2D.shape = CircleShape2D.new()
	_refresh_children_proprerties()
	
func get_gravity_at(point: Vector2) -> Vector2:
	var center = $GravityArea.global_position + $GravityArea.gravity_point_center
	var direction = point.direction_to(center).normalized()
	
 	# Set arbitrary direction if the point is exactly at center of gravity
	if direction.is_zero_approx():
		direction = Vector2(0, 1)
	
	var distance_squared = max(0.0001, point.distance_squared_to(center))
	var _gravity = $GravityArea.gravity / distance_squared * $GravityArea.gravity_point_unit_distance ** 2
	
	return direction * _gravity
