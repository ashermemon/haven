
shader_type spatial;
render_mode unshaded, fog_disabled, depth_draw_never, depth_test_disabled, cull_disabled;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;

uniform float saturation : hint_range(0.5, 2.0) = 1.25;
uniform float contrast : hint_range(0.5, 2.0) = 1.08;
uniform float brightness : hint_range(0.5, 2.0) = 1.08;

uniform float color_levels : hint_range(2.0, 16.0) = 6.0;
uniform float toon_strength : hint_range(0.0, 1.0) = 0.30;

uniform vec3 shadow_tint : source_color = vec3(0.94, 0.95, 1.0);
uniform vec3 highlight_tint : source_color = vec3(1.0, 1.0, 0.92);
uniform float tint_strength : hint_range(0.0, 1.0) = 0.10;

float luminance(vec3 c) {
    return dot(c, vec3(0.299, 0.587, 0.114));
}

void fragment() {
    vec2 uv = SCREEN_UV;

    vec3 col = texture(screen_texture, uv).rgb;

    float lum = luminance(col);
    col = mix(vec3(lum), col, saturation);

    col = (col - 0.5) * contrast + 0.5;
    col *= brightness;

    float original_lum = luminance(col);
    float quantized = floor(original_lum * (color_levels - 1.0) + 0.5)
        / (color_levels - 1.0);

    float toon_lum = mix(original_lum, quantized, toon_strength);

    col *= toon_lum / max(original_lum, 0.001);

    float light_mask = smoothstep(0.15, 0.85, toon_lum);
    vec3 tint = mix(shadow_tint, highlight_tint, light_mask);
    col = mix(col, col * tint, tint_strength);

    ALBEDO = clamp(col, vec3(0.0), vec3(1.0));
}
