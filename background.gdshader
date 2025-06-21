// Tells Godot this is a shader for 2D rendering
shader_type canvas_item;

// This is a variable you can change in the Godot Inspector
// It controls the color of the bottom of the sky
uniform vec4 bottom_color : source_color = vec4(0.3, 0.7, 1.0, 1.0);

// This variable controls the color for the top of the sky
uniform vec4 top_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

// The 'fragment' function runs for every single pixel of the object
// this shader is applied to.
void fragment() {
    // 'UV' is the normalized coordinate of the pixel on the texture.
    // UV.y is 0.0 at the top and 1.0 at the bottom.
    // We use 'mix' to blend the two colors. The third argument
    // determines the balance. When UV.y is 0, we get 100% top_color.
    // When UV.y is 1, we get 100% bottom_color.
    vec4 mixed_color = mix(top_color, bottom_color, UV.y);

    // 'COLOR' is the final output color for the pixel.
    COLOR = mixed_color;
}