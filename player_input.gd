extends MultiplayerSynchronizer

# Set via RPC to simulate is_action_just_pressed.
@export var jumping := false

# Synchronized property.
@export var direction := 0.0

func _ready():
	# Only process for the local player
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

@rpc("call_local")
func jump():
	jumping = true

func _process(_delta):
	direction = Input.get_axis("walk_left", "walk_right")
	if Input.is_action_just_pressed("jump"):
		jump.rpc()
	

