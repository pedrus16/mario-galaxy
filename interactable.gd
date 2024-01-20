extends Area2D

class_name Interactable

signal player_interacted(player: Player)

var player = null
var player_parent = null

func interact(player: Player) -> bool:
	player_interacted.emit(player)
	return true
