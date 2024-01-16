@tool
extends Node2D

@export_range(0, 100000) var radius := 1000.0:
	set(new_radius):
		radius = new_radius
		queue_redraw()
		
@export var speed := 600.0
@export var rotation_speed := 10.0

var children: Array[Node] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	children = get_children().filter(func(child):
		return child is AnimatableBody2D
	)

func draw_circle_arc(center, _radius, color):
	var nb_points = 64
	var points_arc = PackedVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(i * 360.0 / nb_points)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * _radius)

	for index_point in range(nb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color)

func _draw():
	draw_circle_arc(position, radius, Color(1, 1, 1, 0.5))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	for child in children:
		var body := child as AnimatableBody2D
		var _radius = body.position.distance_to(position)
		var direction = body.position.direction_to(position).rotated(deg_to_rad(90))
		body.transform = Transform2D(deg_to_rad(body.rotation_degrees + (rotation_speed * delta)), body.position + direction * speed * delta)
		#body.constant_linear_velocity = direction * speed
		#body.constant_angular_velocity = deg_to_rad(rotation_speed)

