@tool
extends AnimatableBody2D
class_name Planet

## Radius of the planet body in meters.
@export_range(1, 10000) var radius := 5.0:
	set(new_radius):
		radius = new_radius
		if not is_inside_tree():
			return
		$Collision.shape.radius = new_radius * 100
		$Gravity.gravity_point_unit_distance = new_radius * 100
	get:
		return radius
		
## Gravity at the surface in m/s²
@export_range(0, 10000) var gravity := 9.8:
	set(new_gravity):
		gravity = new_gravity
		$Gravity.gravity = new_gravity * 100
	get:
		return gravity
		
## Height from surface in meters that will influence player's up direction
@export_range(0, 10000) var influence_height := 5.0:
	set(new_height):
		influence_height = new_height
		if not is_inside_tree():
			return
		$InfluenceArea/Collision.shape.set_radius(radius * 100 + influence_height * 100)
	get:
		return influence_height
		
@export var orbit_radius := 1000.0

@export var color := Color(1, 1, 1, 1):
	set(new_color):
		color = new_color
		queue_redraw()
		
func _refresh_children_proprerties():
	$Collision.shape.set_radius(radius * 100)
	$InfluenceArea/Collision.shape.set_radius(radius * 100 + influence_height * 100)
	$Gravity.gravity = gravity * 100
	$Gravity.gravity_point_unit_distance = radius * 100

# Called when the node enters the scene tree for the first time.
func _ready():
	$Collision.shape = CircleShape2D.new()
	$InfluenceArea/Collision.shape = CircleShape2D.new()
	_refresh_children_proprerties()
	
func _draw():
	draw_circle($Collision.position, $Collision.shape.radius, color)
	
func _on_influence_area_body_entered(body):
	if body is Player:
		body.current_planet = self

func _on_influence_area_body_exited(body):
	if body is Player:
		body.current_planet = null
	
func get_gravity_at(point: Vector2) -> Vector2:
	var center = global_position
	var direction = point.direction_to(center).normalized()
	
 	# Set arbitrary direction if the point is exactly at center of gravity
	if direction.is_zero_approx():
		direction = Vector2(0, 1)
	
	var distance_squared = max(0.0001, point.distance_squared_to(center))
	var _gravity = (gravity * 100) / distance_squared * (radius * 100) ** 2
	
	return direction * _gravity
	
func get_gravity_center():
	return global_position
