extends Area2D

signal body_picked_up(body: RigidBody2D)

func try_pickup() -> bool:
	for body in get_overlapping_bodies():
		if body is RigidBody2D:
			body_picked_up.emit(body)
			return true
			break
	return false

