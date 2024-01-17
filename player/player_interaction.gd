extends Area2D

func try_interacting(player: Player):
	for area in get_overlapping_areas():
		if area is Interactable:
			area.interact(player)
			break

