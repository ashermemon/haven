
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
uniform float hex_scale = 0.3;
uniform float hex_line_width = 0.015;
uniform float hex_warp = 0.0;
uniform float hex_speed = 0.15;
uniform float hex_strength : hint_range(0.0, 1.0) = 0.9;

group_uniforms foam;
uniform float foam_noise = 0.12;
uniform float contact_foam_width = 0.06;

group_uniforms glints;
uniform float sparkle_amount : hint_range(0.0, 0.2) = 0.0;
uniform float sparkle_scale = 12.0;

varying vec3 world_pos;

uniform sampler2D depth_tex : hint_depth_texture, repeat_disable, filter_nearest;

uniform vec4 impact_0 = vec4(0.0);
uniform vec4 impact_1 = vec4(0.0);
uniform vec4 impact_2 = vec4(0.0);
uniform vec4 impact_3 = vec4(0.0);

uniform float ripple_speed = 1.8;
uniform float ripple_width = 0.07;
uniform float ripple_lifetime = 1.8;


float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
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



float hex_grid(vec2 p) {

    const float SQRT3 = 1.7320508075688772;
    const float APOTHEM = 0.8660254037844386;

    float q = p.x / SQRT3 - p.y / 3.0;
    float r = p.y * (2.0 / 3.0);

    vec3 cube = vec3(
        q,
        -q - r,
        r
    );

  
    vec3 rounded = round(cube);

   
    vec3 diff = abs(rounded - cube);

    if (diff.x > diff.y && diff.x > diff.z) {
        rounded.x = -rounded.y - rounded.z;
    }
    else if (diff.y > diff.z) {
        rounded.y = -rounded.x - rounded.z;
    }
    else {
        rounded.z = -rounded.x - rounded.y;
    }

    vec2 center = vec2(
        SQRT3 * (rounded.x + rounded.z * 0.5),
        1.5 * rounded.z
    );


    vec2 local = p - center;

    float d1 = APOTHEM - abs(local.x);

    float d2 = APOTHEM - abs(
        dot(local, vec2(0.5, 0.8660254037844386))
    );

    float d3 = APOTHEM - abs(
        dot(local, vec2(-0.5, 0.8660254037844386))
    );

    return min(d1, min(d2, d3));
}


void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}


float calculate_ripple(vec2 uv, vec4 impact) {
    if (impact.z < 0.0 || impact.z > ripple_lifetime) {
        return 0.0;
    }

    float dist = distance(uv, impact.xy);

    float radius = impact.z * ripple_speed;

    float ring = 1.0 - smoothstep(
        ripple_width * 0.5,
        ripple_width,
        abs(dist - radius)
    );

    float fade = 1.0 - smoothstep(
        0.0,
        ripple_lifetime,
        impact.z
    );

    return ring * fade * impact.w;
}

void fragment() {

 

    float raw = texture(depth_tex, SCREEN_UV).r;

    vec3 ndc = vec3(
        SCREEN_UV * 2.0 - 1.0,
        raw * 2.0 - 1.0
    );

    vec4 view_pos = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
    view_pos.xyz /= view_pos.w;

    vec3 scene_world = (INV_VIEW_MATRIX * vec4(view_pos.xyz, 1.0)).xyz;

    float depth_h = max(world_pos.y - scene_world.y, 0.0);

    vec2 uv = world_pos.xz;
	
	// WATER IMPACT RIPPLES



    float t = clamp(depth_h / max_depth, 0.0, 1.0);

    vec3 col = mix(shallow_color.rgb, deep_color.rgb, t);


    vec2 bp = uv * patch_scale + vec2(TIME * 0.02, -TIME * 0.015);

    float nb = vnoise(bp) * 0.75
             + vnoise(bp * 2.0 + 11.0) * 0.25;

    float blob = smoothstep(
        patch_threshold - patch_softness,
        patch_threshold + patch_softness,
        nb
    );

    blob *= smoothstep(0.3, 0.9, t);

    col = mix(col, patch_color.rgb, blob * patch_strength);


	float ripple = 0.0;

	ripple += calculate_ripple(uv, impact_0);
	ripple += calculate_ripple(uv, impact_1);
	ripple += calculate_ripple(uv, impact_2);
	ripple += calculate_ripple(uv, impact_3);

	ripple = clamp(ripple, 0.0, 1.0);

	col = mix(
	    col,
	    foam_color.rgb,
	    ripple * 0.65
	);

    vec2 p = uv * hex_scale;


    if (hex_warp > 0.001) {
        p += vec2(
            sin(p.y * 2.0 + TIME * hex_speed),
            sin(p.x * 2.0 - TIME * hex_speed)
        ) * hex_warp;
    }

    
	p += vec2(
	    TIME * 0.35,
	    -TIME * 0.25
	);

    float d = hex_grid(p);

 
    float aa = max(fwidth(d), 0.0001);

    float line = 1.0 - smoothstep(
        hex_line_width - aa,
        hex_line_width + aa,
        d
    );

    col = mix(col, line_color.rgb, line * hex_strength);



    if (sparkle_amount > 0.001) {
        float sp = step(
            1.0 - sparkle_amount,
            vnoise(
                uv * sparkle_scale
                + vec2(TIME * 0.35, -TIME * 0.25)
            )
        );

        col = mix(col, foam_color.rgb, sp);
    }



    float wob = (
        vnoise(uv * 1.5 + vec2(TIME * 0.05, TIME * 0.03)) - 0.5
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

    vec3 tone = mix(shadow_tint.rgb, vec3(1.0), lit);

    DIFFUSE_LIGHT += tone * LIGHT_COLOR / PI;
}
