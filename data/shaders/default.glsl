// #pragma sokol @ctype mat4 @import("math.zig").Mat4

#pragma sokol @vs vs
// uniform vs_params {
//     mat4 mvp;
// };

in vec4 pos;
in vec4 col;
in vec2 texc;

out vec4 color;
out vec2 uv;

void main() {
    gl_Position = pos;
    color = col;
    uv = texc;
}
#pragma sokol @end

#pragma sokol @fs fs
uniform sampler2D tex;

in vec4 color;
in vec2 uv;
out vec4 frag_color;

void main() {
    frag_color = texture(tex, uv);// * color;
    // frag_color = vec4(uv, 0.0, 1.0);
}
#pragma sokol @end

#pragma sokol @program texcube vs fs