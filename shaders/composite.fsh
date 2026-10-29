#version 120

uniform sampler2D colortex0;

const float WARMTH = 0.10; // [-0.10 0.00 0.05 0.10 0.15 0.20]
const float CONTRAST = 1.08; // [0.90 0.95 1.00 1.05 1.08 1.12 1.18]
const float VIGNETTE = 0.12; // [0.00 0.05 0.10 0.12 0.18 0.25]

void main() {
    vec2 uv = gl_TexCoord[0].st;
    vec3 color = texture2D(colortex0, uv).rgb;

    // Gentle contrast and warm cinematic color grading.
    color = (color - vec3(0.5)) * CONTRAST + vec3(0.5);
    color.r += WARMTH * 0.65;
    color.g += WARMTH * 0.12;
    color.b -= WARMTH * 0.35;

    // Subtle vignette, kept light so the image remains clear.
    vec2 centered = uv * 2.0 - 1.0;
    float edge = dot(centered, centered);
    float vignette = 1.0 - VIGNETTE * smoothstep(0.25, 2.0, edge);
    color *= vignette;

    gl_FragColor = vec4(clamp(color, 0.0, 1.0), 1.0);
}
