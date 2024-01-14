shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	
	
	
	COLOR = vec4(fract(UV * 3.0), 0.0, 1.0);
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
