
shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear;

uniform float shading_strength : hint_range(0.0, 1.0) = 0.25;
uniform float color_levels : hint_range(2.0, 8.0) = 4.0;
uniform float saturation : hint_range(0.0, 2.0) = 1.05;
uniform float contrast : hint_range(0.5, 1.5) = 1.0;
uniform float outline_strength : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec3 col = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;

    float luminance = dot(col, vec3(0.299, 0.587, 0.114));

    float levels = max(color_levels - 1.0, 1.0);
    float stepped = floor(luminance * levels + 0.5) / levels;

    float new_luminance = mix(luminance, stepped, shading_strength);

    vec3 toon = col * (new_luminance / max(luminance, 0.001));

    float gray = dot(toon, vec3(0.299, 0.587, 0.114));
    toon = mix(vec3(gray), toon, saturation);
    toon = (toon - 0.5) * contrast + 0.5;

    vec2 px = SCREEN_PIXEL_SIZE;

    float l = dot(texture(SCREEN_TEXTURE, SCREEN_UV - vec2(px.x, 0.0)).rgb,
                  vec3(0.299, 0.587, 0.114));
    float r = dot(texture(SCREEN_TEXTURE, SCREEN_UV + vec2(px.x, 0.0)).rgb,
                  vec3(0.299, 0.587, 0.114));

    float u = dot(texture(SCREEN_TEXTURE, SCREEN_UV - vec2(0.0, px.y)).rgb,
                  vec3(0.299, 0.587, 0.114));
    float d = dot(texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, px.y)).rgb,
                  vec3(0.299, 0.587, 0.114));

    float edge = abs(l-r) + abs(u-d);

    toon *= 1.0 - smoothstep(0.15, 0.5, edge) * outline_strength;

    COLOR = vec4(clamp(toon, 0.0, 1.0), 1.0);
}
