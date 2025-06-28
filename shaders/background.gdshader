shader_type canvas_item;

// ------ Sky Gradient Uniforms ------
uniform vec4 bottom_color : source_color = vec4(0.3, 0.7, 1.0, 1.0);
uniform vec4 top_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

uniform float star_density : hint_range(0.9, 0.999) = 0.995;
uniform float star_speed : hint_range(0.0, 5.0) = 0.3;
uniform float star_size : hint_range(0.0, 0.5) = 0.5;

// A simple function to generate a pseudo-random number from a 2D vector.
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// The 'fragment' function runs for every pixel.
void fragment() {
    // 1. Create the base sky gradient (same as before).
    vec4 sky_color = mix(top_color, bottom_color, UV.y);

    // 2. Generate the stars.
    // We scale UV to create a grid. The bigger the number, the more cells.
    vec2 star_uv = UV * 300.0;

    // Get the integer coordinate of the cell (the star's unique ID).
    vec2 cell_id = floor(star_uv);
    // Get the fractional coordinate within the cell (0.0 to 1.0).
    vec2 cell_uv = fract(star_uv);

    // Generate a random number for this star's cell.
    float star_rand = random(cell_id);

    vec3 star_final_color = vec3(0.0);

    // We only draw a star if its random number is above our density threshold.
    if (star_rand > star_density) {
        // Make the star twinkle using TIME and its unique random value.
        float twinkle = sin((TIME * star_speed) + (star_rand * 6.28)) * 0.5 + 0.5;

        // Calculate distance from the center of the cell to draw a dot.
        float dist = distance(cell_uv, vec2(0.5));
        // Use smoothstep to create a soft, anti-aliased dot for the star.
        float star_dot = 1.0 - smoothstep(0.0, star_size, dist);

        // Final star color is the dot shape, multiplied by its twinkle brightness.
        star_final_color = vec3(star_dot * twinkle);
    }

    // 3. Fade the stars out near the horizon.
    // We use smoothstep to create a fade mask based on the vertical UV coordinate.
    // Stars will be fully visible above y=0.4, and fully faded out at y=0.6.
    float fade_mask = 1.0 - smoothstep(0.4, 0.6, UV.y);

    // 4. Combine the sky and the stars.
    // We add the final star color (multiplied by the fade mask) to the sky color.
    COLOR.rgb = sky_color.rgb + (star_final_color * fade_mask);
    COLOR.a = sky_color.a;
}