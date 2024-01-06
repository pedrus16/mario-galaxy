extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

var players = {}

const DEFAULT_HOST_ADDRESS = 'localhost'
const DEFAULT_PORT = 10567
const MAX_PEERS = 12

func _ready():
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)

func host():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(DEFAULT_PORT, MAX_PEERS)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_player_connected)
	
	var world = preload("res://world.tscn").instantiate()
	$/root.add_child(world)
	$/root/Menu.hide()
	
	print("SPAWN PLAYER FOR ", peer.get_unique_id())
	spawn_player(multiplayer.get_unique_id())
	
func join(ip = ""):
	if ip.is_empty():
		ip = DEFAULT_HOST_ADDRESS
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, DEFAULT_PORT)
	multiplayer.multiplayer_peer = peer
	
func _on_player_connected(id):
	print("Player Connected: ", id)
	spawn_player(id)	
	#_register_player.rpc_id(id, {})
	
func _on_player_disconnected(id):
	print("Player Disconnected: ", id)
	players.erase(id)
	player_disconnected.emit(id)
	
func _on_connected_ok():
	print("Connected to Server")
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = {}
	player_connected.emit(peer_id, {})
	
	var world = preload("res://world.tscn").instantiate()	
	$/root.add_child(world)
	$/root/Menu.hide()
	
func _on_server_disconnected():
	print("Server Disconnected")
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()
	
@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)

func spawn_player(peer_id):
	var player = load("res://player.tscn").instantiate()
	player.position = $/root/World/Spawn.position
	player.name = str(peer_id)
	$/root/World.add_child(player, true)