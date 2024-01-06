extends CharacterBody2D

const move_speed = 250.0
const jump_speed = 400.0

var planets = []

var direction = 0
var jumping = false

@onready var camera = $Camera2D

func _enter_tree():
	set_multiplayer_authority(name.to_int())

# Called when the node enters the scene tree for the first time.
func _ready():
	if not is_multiplayer_authority():
		return
		
	planets = get_tree().get_nodes_in_group("planet")
	camera.make_current()
	
#func _process(_delta):
	#if $Camera2D:
		#$Camera2D.rotation = up_direction.angle() + PI / 2
		
func _physics_process(delta):
	$Sprite2D.rotation = get_up_direction().angle() + PI / 2
	camera.rotation = get_up_direction().angle() + PI / 2
	direction = 0
	
	if is_multiplayer_authority():
		if Input.is_action_pressed("walk_left"):
			direction += -1
		if Input.is_action_pressed("walk_right"):
			direction += 1

		var _velocity = get_real_velocity()
		for planet in planets:
			# Computing gravity
			var gravity = planet.get_gravity_at(position)
			var gravity_direction = gravity.normalized()
			_velocity += gravity * delta
			
			set_up_direction(-gravity_direction)
			$Collision.rotation = up_direction.angle() + PI / 2
			
			# Walk
			if is_on_floor():
				var move_dir = up_direction.rotated(PI / 2) * direction
				_velocity = move_dir * move_speed
			
			# Jump
			if is_multiplayer_authority() and Input.is_action_just_pressed("jump") and is_on_floor():
				jumping = true
				_velocity += up_direction * jump_speed
			
			set_velocity(_velocity)
			move_and_slide()

