const Allocator = @import("std").mem.Allocator;

const sokol = @import("sokol/sokol.zig");
const sg = sokol.gfx;
const app = sokol.app;

usingnamespace @import("math.zig");
const Texture = @import("texture.zig").Texture;
const Vertex = @import("gfx.zig").Vertex;

const shader = @import("default.glsl.zig");

const tile_sz: f32 = 16.0;
const vertices = [_]Vertex {
    .{ .x = 0, .y = 0, .z = 0, .color = 0, .u = 0, .v = 0 },
    .{ .x = 1, .y = 0, .z = 0, .color = 0, .u = 0, .v = 0 },
    .{ .x = 1, .y = 1, .z = 0, .color = 0, .u = 0, .v = 0 }
};
const indices = [_]u16 {
    0, 1, 2
};

pub const Sprite = struct {
    texture: Texture,
    pos: Vec2 = Vec2.zero(),
    size: Vec2 = Vec2.new(tile_sz, tile_sz),
    scale: Vec2 = Vec2.one(),
    texc: Vec2 = Vec2.zero(),
    texsize: Vec2 = Vec2.one(),
    rotation: f32 = 0.0,
};

pub const SpriteBatcher = struct {
    allocator: *Allocator,
    bind: sg.Bindings = .{},
    pip: sg.Pipeline = .{},
    pass_action: sg.PassAction = .{},

    pub fn init(self: *SpriteBatcher) void {
        var pip_desc: sg.PipelineDesc = .{
            .shader = sg.makeShader(shader.texcubeShaderDesc(sg.queryBackend())),
            .index_type = .UINT16,
            .depth = .{
                .compare = .LESS_EQUAL,
                .write_enabled = true,
            },
            // .cull_mode = .BACK
        };
        pip_desc.layout.attrs[shader.ATTR_vs_pos].format = .FLOAT3;
        pip_desc.layout.attrs[shader.ATTR_vs_col].format = .UBYTE4N;
        pip_desc.layout.attrs[shader.ATTR_vs_texc].format = .SHORT2N;
        self.pip = sg.makePipeline(pip_desc);

        self.pass_action.colors[0] = .{ 
            .action = .CLEAR, 
            .value = .{ .r=0.85, .g=0.25, .b=0.25, .a=1 } 
        };

        self.bind.vertex_buffers[0] = sg.makeBuffer(.{.data = sg.asRange(vertices)});
        self.bind.index_buffer = sg.makeBuffer(.{.type = .INDEXBUFFER, .data = sg.asRange(indices)});
    }

    pub fn drawSprite(self: *SpriteBatcher, spr: *Sprite) void {
        self.bind.fs_images[shader.SLOT_tex].id = spr.texture.getId();

        sg.beginDefaultPass(self.pass_action, app.width(), app.height());
        sg.applyPipeline(self.pip);
        sg.applyBindings(self.bind);
        // sg.applyUniforms(.VS, shader.SLOT_vs_params, sg.asRange(vs_params));
        sg.draw(0, 3, 1);
        sg.endPass();
        sg.commit();
    }
};