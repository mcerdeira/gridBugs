shader_type canvas_item;
uniform bool on;
uniform vec3 color : source_color = vec3(1.0);

void fragment() {
	if(on){
	    if (texture(TEXTURE, UV).a == 0.0) {
	        discard;
	    }
	    COLOR = vec4(color.r, color.g, color.b, texture(TEXTURE, UV).a);
	}
}