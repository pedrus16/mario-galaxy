@tool
extends Node2D

## Radius of the planet body in meters.
@export_range(1, 10000) var radius: float = 500:
	set(new_radius):
		radius = new_radius
		$GravityArea.set_gravity_point_unit_distance(new_radius * 100)
		$GravityArea/Collision.shape.set_radius(new_radius * 100 * gravity)
		$Body/Collision.shape.set_radius(new_radius * 100)
	get:
		return radius
		
## Gravity at the surface in m/s²
@export_range(0, 10000) var gravity: float = 9.8:
	set(new_gravity):
		gravity = new_gravity
		$GravityArea.set_gravity(new_gravity * 100)
	get:
		return gravity
		
## Height from surface in meters that will influence player's up direction
@export_range(0, 10000) var influence_height: float = 50:
	set(new_height):
		influence_height = new_height
		$InfluenceArea/CollisionShape2D.shape.set_radius(radius + new_height)
	get:
		return influence_height

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

	
func _draw():
	# Draw shaded regions to show the areas.
	draw_circle($Body.position, $Body/Collision.shape.radius,
				Color(1, 1, 1, 0.1))
	
func get_gravity_at(point: Vector2):
	var center = $GravityArea.position + $GravityArea.gravity_point_center
	var direction = point.direction_to(center).normalized()
	var _gravity = $GravityArea.gravity / point.distance_squared_to(center) * $GravityArea.gravity_point_unit_distance ** 2
	
	#print("dist:", point.distance_to(center), " gravity:", gravity)
	
	return direction * _gravity
