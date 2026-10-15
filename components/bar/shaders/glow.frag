#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
    vec4 colorA;
    vec4 colorB;
    vec4 colorC;
    vec4 colorD;
    float glowRadius;
    float strength;
    float warp;
    vec2 texelSize;
    vec4 haloTint;
};
layout(binding = 1) uniform sampler2D source;

void main() {
    vec4 base = texture(source, qt_TexCoord0);
    vec2 texel = texelSize;

    // Outer halo: for each direction the reach is distorted by travelling
    // waves, and the whole ring breathes with time.
    const int rings = 3;
    const int dirs = 24;
    float halo = 0.0;
    for (int i = 0; i < dirs; ++i) {
        float a = 6.2831853 * float(i) / float(dirs);
        float wobble = 1.0 + warp * (0.5 * sin(3.0 * a + time * 2.0) + 0.5 * sin(5.0 * a - time * 3.0));
        float reach = glowRadius * (0.85 + 0.15 * sin(time)) * wobble;
        vec2 dir = vec2(cos(a), sin(a));
        for (int s = 1; s <= rings; ++s) {
            float t = float(s) / float(rings);
            float falloff = 1.0 - (t - 1.0 / float(rings));
            halo = max(halo, texture(source, qt_TexCoord0 + dir * reach * t * texel).a * falloff);
        }
    }

    // Hyprland-style rotating conic gradient across four theme colours,
    // lifted towards haloTint (white on dark, a dark tone on light so it reads as a shadow).
    vec2 p = qt_TexCoord0 - vec2(0.5);
    float ang = atan(p.y, p.x) - time;
    float seg = fract(ang / 6.2831853) * 4.0;
    int idx = int(floor(seg));
    float f = smoothstep(0.0, 1.0, fract(seg));
    vec3 c0 = colorA.rgb, c1 = colorB.rgb, c2 = colorC.rgb, c3 = colorD.rgb;
    vec3 ca = idx == 0 ? c0 : idx == 1 ? c1 : idx == 2 ? c2 : c3;
    vec3 cb = idx == 0 ? c1 : idx == 1 ? c2 : idx == 2 ? c3 : c0;
    vec3 glowRgb = mix(mix(ca, cb, f), haloTint.rgb, 0.25);

    float pulse = mix(0.7, 1.0, 0.5 + 0.5 * sin(time * 2.0));
    float g = clamp(halo * strength * pulse, 0.0, 1.0) * (1.0 - base.a);

    // Premultiplied alpha: the glow sits behind the icon.
    fragColor = vec4(base.rgb + glowRgb * g, base.a + g) * qt_Opacity;
}
