shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float wave_amplitude : hint_range(0.0, 10.0) = 1.0;
uniform float wave_frequency : hint_range(0.0, 20.0) = 8.0;
uniform float wave_speed : hint_range(0.0, 5.0) = 1.0;
uniform vec4 water_tint : source_color = vec4(0.11, 0.30, 0.15, 0.4);

void fragment() {
    vec2 screen_uv = SCREEN_UV;
    float t = TIME * wave_speed;
    float wave_offset = sin(screen_uv.y * wave_frequency + t) * (wave_amplitude * 0.01);
    screen_uv.x += wave_offset;
    vec4 base_color = texture(SCREEN_TEXTURE, screen_uv);
    COLOR = mix(base_color, water_tint, water_tint.a);
}
