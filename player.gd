extends CharacterBody2D
class_name Player

const move_speed := 250.0
const jump_speed := 400.0

var planets = []
var current_planet = null

var direction := 0

@onready var camera := $Camera2D

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
	$PlayerSprite.rotation = get_up_direction().angle() + PI / 2
	camera.rotation = get_up_direction().angle() + PI / 2
	direction = 0
	
	if is_multiplayer_authority():
		if Input.is_action_pressed("walk_left"):
			direction += -1
		if Input.is_action_pressed("walk_right"):
			direction += 1
		if Input.is_action_just_pressed("zoom_out") and camera.zoom.x > (1.0 / 128.0):
			camera.zoom *= 0.5
		if Input.is_action_just_pressed("zoom_in") and camera.zoom.x < 1:
			camera.zoom *= 2

		# Accumulate gravity from all planets
		var gravity = Vector2()
		for planet in planets:
			# Computing gravity
			gravity += planet.get_gravity_at(global_position)
			
		var _velocity = get_real_velocity()
		_velocity += gravity * delta

		# Align player orientation when entering planet's area of influence
		if current_planet:
			var down_direction = global_position.direction_to(current_planet.get_gravity_center()).normalized()
			if not down_direction.is_zero_approx():
				set_up_direction(-down_direction)
		
		$Collision.rotation = up_direction.angle() + PI / 2
		
		# Walk
		if is_on_floor():
			var move_dir = up_direction.rotated(PI / 2) * direction
			_velocity = move_dir * move_speed
		
		# Jump
		if is_multiplayer_authority() and Input.is_action_just_pressed("jump"):
			_velocity += up_direction * jump_speed
		
		set_velocity(_velocity)
		move_and_slide()

