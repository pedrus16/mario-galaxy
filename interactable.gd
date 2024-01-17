extends Area2D

class_name Interactable

signal player_interacted(player: Player)

var player = null
var player_parent = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func interact(player: Player):
	player_interacted.emit(player)
