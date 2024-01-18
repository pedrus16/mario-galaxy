extends Node2D

class_name Vehicle

var player: Player = null

func _physics_process(delta):
	if not player:
		return
	
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
	$Node2D/PlayerRemoteTransform2D2.remote_path = _player.get_path()	
	player.set_physics_process(false)
	player.camera.rotation = 0
	player.visible = false
	player.in_vehicle = true

func exit():
	if not player:
		return
		
	$Node2D/PlayerRemoteTransform2D2.remote_path = NodePath("")
	player.set_physics_process(true)
	player.visible = true
	player.rotation = 0
	player.velocity = $RigidBody2D.linear_velocity
	player.move_and_slide()
	player.in_vehicle = false
	player = null
	
	
func _on_entry_area_player_interacted(interacting_player: Player):
	if player && interacting_player == player:
		exit()
	elif not interacting_player.in_vehicle:
		enter(interacting_player)


