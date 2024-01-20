extends Area2D

func try_interacting(player: Player) -> bool:
	for area in get_overlapping_areas():
		if area is Interactable:
			return area.interact(player)
			break
	return false

