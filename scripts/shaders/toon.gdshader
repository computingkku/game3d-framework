shader_type canvas_item;
render_mode unshaded;

// ต้องประกาศแบบนี้ใน 4.4+
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// ปรับได้
uniform int  QUANT_LEVELS : hint_range(2, 8) = 3;   // จำนวนขั้นสี
uniform float EDGE_STRENGTH : hint_range(0.0, 4.0) = 1.2;
uniform float EDGE_THICKNESS : hint_range(0.5, 3.0) = 1.0;
uniform vec3  EDGE_COLOR = vec3(0.0);

// Sobel จากความสว่างของสี (ไม่ใช้ depth/normal)
float luma(vec3 c){ return dot(c, vec3(0.2126, 0.7152, 0.0722)); }

void fragment() {
    vec3 src = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;

    // 1) toon: ลดระดับสีทั้งภาพ
    float L = float(max(2, QUANT_LEVELS));
    vec3 q = floor(src * L) / L;

    // 2) เส้นขอบจากสี (Sobel)
    vec2 px = SCREEN_PIXEL_SIZE * EDGE_THICKNESS;
    vec2 o[8] = vec2[](
        vec2(-px.x,-px.y), vec2(0.0,-px.y), vec2(px.x,-px.y),
        vec2(-px.x, 0.0 ),                   vec2(px.x, 0.0 ),
        vec2(-px.x, px.y), vec2(0.0, px.y),  vec2(px.x, px.y)
    );
    float s[8];
    for (int i=0;i<8;i++){
        vec3 c = texture(SCREEN_TEXTURE, SCREEN_UV + o[i]).rgb;
        s[i] = luma(c);
    }
    float gx = (s[2] + 2.0*s[4] + s[7]) - (s[0] + 2.0*s[3] + s[5]);
    float gy = (s[5] + 2.0*s[6] + s[7]) - (s[0] + 2.0*s[1] + s[2]);
    float edge = smoothstep(0.08, 0.22, clamp(length(vec2(gx, gy)) * EDGE_STRENGTH, 0.0, 1.0));

    vec3 out_col = mix(q, EDGE_COLOR, edge);
    COLOR = vec4(out_col, 1.0);
}
