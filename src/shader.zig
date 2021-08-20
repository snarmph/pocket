const sg = @import("sokol/sokol.zig").gfx;
const default = @import("default.glsl.zig");

pub const Shader = struct {
    id: sg.Shader = undefined,

    fn makeShader(desc: sg.ShaderDes) Shader {
        return .{
            .id = sg.makeShader(desc)
        };
    }
};

pub var default_shader = Shader.makeShader(default);