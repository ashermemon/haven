
shader_type spatial;


render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_disabled;


group_uniforms colors;

uniform vec4 shallow_color : source_color = vec4(0.30, 0.80, 0.85, 1.0);
uniform vec4 deep_color : source_color = vec4(0.07, 0.25, 0.85, 1.0);
uniform vec4 patch_color : source_color = vec4(0.04, 0.16, 0.66, 1.0);
uniform vec4 line_color : source_color = vec4(0.62, 0.96, 1.00, 1.0);
uniform vec4 foam_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 shadow_tint : source_color = vec4(0.50, 0.58, 0.95, 1.0);

uniform float shallow_alpha : hint_range(0.0, 1.0) = 0.70;
uniform float water_alpha : hint_range(0.0, 1.0) = 0.90;


group_uniforms water;

uniform float max_depth = 0.9;


group_uniforms patches;

uniform float patch_scale = 0.18;
uniform float patch_threshold : hint_range(0.0, 1.0) = 0.5;
uniform float patch_softness : hint_range(0.0, 0.3) = 0.04;
uniform float patch_strength : hint_range(0.0, 1.0) = 0.8;


group_uniforms cell_lines;

uniform float cell_scale = 0.3;
uniform float line_width = 0.14;
uniform float cell_speed = 0.4;
uniform float cell_warp = 0.25;
uniform float line_strength : hint_range(0.0, 1.0) = 0.9;


group_uniforms foam;

uniform float foam_noise = 0.12;
uniform float contact_foam_width = 0.06;

group_uniforms glints;

uniform float sparkle_amount : hint_range(0.0, 0.2) = 0.0;
uniform float sparkle_scale = 12.0;


varying vec3 world_pos;

uniform sampler2D depth_tex : hint_depth_texture, repeat_disable, filter_nearest;


float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

vec2 hash22(vec2 p) {
    p = vec2(
        dot(p, vec2(127.1, 311.7)),
        dot(p, vec2(269.5, 183.3))
    );
    return fract(sin(p) * 43758.5453);
}

float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    f = f * f * (3.0 - 2.0 * f);

    float a = hash21(i);
    float b = hash21(i + vec2(1.0, 0.0));
    float c = hash21(i + vec2(0.0, 1.0));
    float d = hash21(i + vec2(1.0, 1.0));

    return mix(
        mix(a, b, f.x),
        mix(c, d, f.x),
        f.y
    );
}


void voronoi(vec2 x, float tm, out float f1, out float f2) {
    vec2 n = floor(x);
    vec2 f = fract(x);

    f1 = 8.0;
    f2 = 8.0;

    for (int j = -1; j <= 1; j++) {
        for (int i = -1; i <= 1; i++) {
            vec2 g = vec2(float(i), float(j));

            vec2 o = hash22(n + g);
            o = 0.5 + 0.5 * sin(tm + 6.2831 * o);

            vec2 r = g + o - f;
            float d = dot(r, r);

            if (d < f1) {
                f2 = f1;
                f1 = d;
            } else if (d < f2) {
                f2 = d;
            }
        }
    }

    f1 = sqrt(f1);
    f2 = sqrt(f2);
}



void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {


    float raw = texture(depth_tex, SCREEN_UV).r;

    vec3 ndc = vec3(
        SCREEN_UV * 2.0 - 1.0,
        raw * 2.0 - 1.0
    );

    vec4 view_pos = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
    view_pos.xyz /= view_pos.w;

    vec3 scene_world = (
        INV_VIEW_MATRIX * vec4(view_pos.xyz, 1.0)
    ).xyz;

    float depth_h = max(world_pos.y - scene_world.y, 0.0);

    vec2 uv = world_pos.xz;

    float t = clamp(depth_h / max_depth, 0.0, 1.0);
    vec3 col = mix(shallow_color.rgb, deep_color.rgb, t);

 
    vec2 bp = uv * patch_scale
        + vec2(TIME * 0.02, -TIME * 0.015);

    float nb =
        vnoise(bp) * 0.75 +
        vnoise(bp * 2.0 + 11.0) * 0.25;

    float blob = smoothstep(
        patch_threshold - patch_softness,
        patch_threshold + patch_softness,
        nb
    );

    blob *= smoothstep(0.3, 0.9, t);

    col = mix(
        col,
        patch_color.rgb,
        blob * patch_strength
    );


    vec2 p = uv * cell_scale;

    p += (
        vec2(
            vnoise(p * 1.3 + TIME * 0.05),
            vnoise(p * 1.3 + 7.7 - TIME * 0.05)
        ) - 0.5
    ) * cell_warp;

    float f1;
    float f2;

    voronoi(p, TIME * cell_speed, f1, f2);

    float edge = f2 - f1;
    float aa = fwidth(edge);

    float line = 1.0 - smoothstep(
        line_width - aa,
        line_width + aa,
        edge
    );

    col = mix(
        col,
        line_color.rgb,
        line * line_strength
    );

 
    float sp = step(
        1.0 - sparkle_amount,
        vnoise(
            uv * sparkle_scale
            + vec2(TIME * 0.35, -TIME * 0.25)
        )
    );

    col = mix(col, foam_color.rgb, sp);

  
    float wob = (
        vnoise(
            uv * 1.5
            + vec2(TIME * 0.05, TIME * 0.03)
        ) - 0.5
    ) * foam_noise * 2.0;

    float contact = 1.0 - smoothstep(
        contact_foam_width * 0.5,
        contact_foam_width,
        depth_h - wob * 0.5
    );

    col = mix(col, foam_color.rgb, contact);

   
    float a = mix(
        shallow_alpha,
        water_alpha,
        smoothstep(0.0, 0.3, depth_h)
    );

    a = max(a, contact);

    ALBEDO = col;
    ALPHA = a;
    ROUGHNESS = 1.0;
}


void light() {
    float lit = smoothstep(0.0, 0.05, ATTENUATION);

    vec3 tone = mix(
        shadow_tint.rgb,
        vec3(1.0),
        lit
    );

    DIFFUSE_LIGHT += tone * LIGHT_COLOR / PI;
}
