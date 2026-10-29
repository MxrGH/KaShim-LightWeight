#version 120

uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform mat4 gbufferProjection;
uniform vec3 sunPosition;
uniform vec3 moonPosition;

const float GODRAY_STRENGTH = 0.32; // [0.00 0.10 0.20 0.32 0.45 0.60 0.80]
const int GODRAY_SAMPLES = 24; // [8 12 16 24 32 40]

vec2 lightScreenPos(vec3 lightPos) {
    vec4 clip = gbufferProjection * vec4(lightPos, 1.0);
    if (abs(clip.w) < 0.0001) return vec2(-2.0);
    return clip.xy / clip.w * 0.5 + 0.5;
}

float raysAt(vec2 uv, vec2 lightUV) {
    vec2 stepUV = (uv - lightUV) / float(GODRAY_SAMPLES);
    vec2 p = uv;
    float sum = 0.0;
    float weight = 1.0;
    for (int i = 0; i < GODRAY_SAMPLES; ++i) {
        p -= stepUV;
        if (p.x < 0.001 || p.x > 0.999 || p.y < 0.001 || p.y > 0.999) break;
        float depth = texture2D(depthtex0, p).r;
        sum += smoothstep(0.999, 1.0, depth) * weight;
        weight *= 0.96;
    }
    return sum / float(GODRAY_SAMPLES);
}

float insideScreen(vec2 p) {
    return step(0.0, p.x) * step(p.x, 1.0) * step(0.0, p.y) * step(p.y, 1.0);
}

void main() {
    vec2 uv = gl_TexCoord[0].st;
    vec3 scene = texture2D(colortex0, uv).rgb;

    vec2 sunUV = lightScreenPos(sunPosition);
    vec2 moonUV = lightScreenPos(moonPosition);
    float sunRays = raysAt(uv, sunUV) * insideScreen(sunUV);
    float moonRays = raysAt(uv, moonUV) * insideScreen(moonUV);

    vec3 dawnTint = vec3(1.00, 0.57, 0.30);
    vec3 moonTint = vec3(0.48, 0.64, 1.00);
    vec3 result = scene
        + dawnTint * sunRays * GODRAY_STRENGTH
        + moonTint * moonRays * GODRAY_STRENGTH * 0.45;

    gl_FragColor = vec4(result, 1.0);
}
