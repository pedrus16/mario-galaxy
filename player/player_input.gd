extends MultiplayerSynchronizer

# Set via RPC to simulate is_action_just_pressed.
@export var jumping := false
@export var interacting := false

# Synchronized property.
@export var direction := 0.0

@export var vehicle_direction := Vector2()

func _ready():
	# Only process for the local player
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

@rpc("call_local")
func jump():
	jumping = true
	
@rpc("call_local")
func interact():
	interacting = true

func _process(_delta):
	direction = Input.get_axis("walk_left", "walk_right")
	vehicle_direction = Input.get_vector("left", "right", "up", "down")
	if Input.is_action_just_pressed("jump"):
		jump.rpc()
	if Input.is_action_just_pressed("interact"):
		interact.rpc()
	

