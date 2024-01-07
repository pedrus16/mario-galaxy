extends Node

const DEFAULT_HOST_ADDRESS := 'localhost'
const DEFAULT_PORT := 10567
const MAX_PEERS := 12

func _ready():
	multiplayer.server_relay = false

func _on_menu_host_clicked():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(DEFAULT_PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return
	multiplayer.multiplayer_peer = peer
	start_game()
	

func _on_menu_join_clicked(address):
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(address, DEFAULT_PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client.")
		return
	multiplayer.multiplayer_peer = peer
	start_game()

func start_game():
	$Menu.hide()
	if multiplayer.is_server():
		change_level.call_deferred(load("res://world.tscn"))

# Call this function deferred and only on the main authority (server).
func change_level(scene: PackedScene):
	# Remove old world if any.
	var world = $World
	for c in world.get_children():
		world.remove_child(c)
		c.queue_free()
	world.add_child(scene.instantiate())

