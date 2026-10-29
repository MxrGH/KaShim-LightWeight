#version 120
uniform sampler2D colortex0;
void main() {
    gl_FragColor = texture2D(colortex0, gl_TexCoord[0].st);
}
