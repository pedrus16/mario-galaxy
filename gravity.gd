extends RigidBody2D

var planets = []

func _ready():
	planets = get_tree().get_nodes_in_group("planet")

func get_combined_gravity() -> Vector2:
	return planets.reduce(func(gravity, planet):
		return gravity + planet.get_gravity_at(global_position)
	, Vector2())

func _integrate_forces(state):
	#state.apply_central_force(get_combined_gravity() * mass)
	state.linear_velocity += get_combined_gravity() * state.step
