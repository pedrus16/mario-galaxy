@tool
extends MeshInstance2D

var radius = 1
var segments = 8

# Called when the node enters the scene tree for the first time.
func _ready():
	mesh = Mesh.new()	
	mesh.PRIMITIVE_TRIANGLE_STRIP
	for i in segments - 1:
		var u = float(i) / segments
		var x = sin(u * PI * 2.0)
		var y = cos(u * PI * 2.0)
		
		var vert = Vector2(x * radius, y * radius)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
