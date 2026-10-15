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
    float cornerRadius;
    vec2 size;
};

// Same rotating four-colour conic blend as glow.frag, filling a rounded rectangle
// (a circle when cornerRadius = half the height and width).
void main() {
    vec2 p = qt_TexCoord0 - vec2(0.5);
    vec2 px = p * size;
    vec2 q = abs(px) - (size * 0.5 - vec2(cornerRadius));
    float d = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - cornerRadius;
    // Feather outwards into the glow, and keep the body translucent like the halo.
    float aa = (1.0 - smoothstep(-1.0, 3.0, d)) * 0.75;

    float ang = atan(p.y, p.x) - time;
    float seg = fract(ang / 6.2831853) * 4.0;
    int idx = int(floor(seg));
    float f = smoothstep(0.0, 1.0, fract(seg));
    vec3 c0 = colorA.rgb, c1 = colorB.rgb, c2 = colorC.rgb, c3 = colorD.rgb;
    vec3 ca = idx == 0 ? c0 : idx == 1 ? c1 : idx == 2 ? c2 : c3;
    vec3 cb = idx == 0 ? c1 : idx == 1 ? c2 : idx == 2 ? c3 : c0;
    vec3 rgb = mix(ca, cb, f);

    fragColor = vec4(rgb * aa, aa) * qt_Opacity;
}
