const std = @import("std");
const Allocator = std.mem.Allocator;

const sokol = @import("sokol/sokol.zig");
const sg = sokol.gfx;
const app = sokol.app;

usingnamespace @import("math.zig");
const Texture = @import("texture.zig").Texture;
const Vertex = @import("gfx.zig").Vertex;

const shader = @import("default.glsl.zig");

const tile_sz: f32 = 16.0;
// number of maximum sprites in a batch
const batch_sz: usize = 10;
// vertices needed for a single sprite
const single_sprite_vertices = 6; 
// buffers size
const vubf_sz = batch_sz * single_sprite_vertices;

const vertices = [_]Vertex {
    .{ .x = -0.5, .y =  0.5, .z = 0.5, .color = 0xff0000ff, .u = 0, .v = 1 },
    .{ .x =  0.5, .y =  0.5, .z = 0.5, .color = 0x00ff00ff, .u = 1, .v = 1 },
    .{ .x =  0.5, .y = -0.5, .z = 0.5, .color = 0x0000ffff, .u = 1, .v = 0 },
    .{ .x = -0.5, .y =  0.5, .z = 0.5, .color = 0xff0000ff, .u = 0, .v = 1 },
    .{ .x =  0.5, .y = -0.5, .z = 0.5, .color = 0x0000ffff, .u = 1, .v = 0 },
    .{ .x = -0.5, .y = -0.5, .z = 0.5, .color = 0xffff00ff, .u = 0, .v = 0 },
};

pub const Sprite = struct {
    texture:  Texture,
    pos:      Vec2 = Vec2.zero(),
    size:     Vec2 = Vec2.new(tile_sz, tile_sz),
    scale:    Vec2 = Vec2.one(),
    rotation: f32  = 0.0,
    origin:   Vec2 = Vec2.new(tile_sz / 2, tile_sz / 2),
    texc:     Vec2 = Vec2.zero(),
    texsize:  Vec2 = Vec2.one(),
};

pub const SpriteBatcher = struct {
    allocator:    *Allocator,
    bind:         sg.Bindings      = .{},
    pip:          sg.Pipeline      = .{},
    pass_action:  sg.PassAction    = .{},
    vbuf:         [vubf_sz]Vertex  = undefined,
    batch:        [batch_sz]Sprite = undefined,
    sprite_count: u32              = 0,

    pub fn init(sb: *SpriteBatcher) void {
        // initialize pipeline
        var pip_desc: sg.PipelineDesc = .{
            .shader = sg.makeShader(shader.texcubeShaderDesc(sg.queryBackend())),
            .cull_mode = .BACK
        };
        pip_desc.layout.attrs[shader.ATTR_vs_pos].format = .FLOAT3;
        pip_desc.layout.attrs[shader.ATTR_vs_col].format = .UBYTE4N;
        pip_desc.layout.attrs[shader.ATTR_vs_texc].format = .FLOAT2;
        sb.pip = sg.makePipeline(pip_desc);

        // set background color
        sb.pass_action.colors[0] = .{
            .action = .CLEAR, 
            .value = .{ .r=0.85, .g=0.25, .b=0.25, .a=1 } 
        };

        // initialize the two buffers
        sb.bind.vertex_buffers[0] = sg.makeBuffer(.{
            .size = @sizeOf(@TypeOf(sb.vbuf)),
            .usage = .STREAM,
        });
    }

    pub fn addSprite(sb: *SpriteBatcher, spr: Sprite) void {
        sb.batch[sb.sprite_count] = spr;
        if(sb.sprite_count == sb.batch.len) {
            sb.flush();
        }
    }

    pub fn flush(sb: *SpriteBatcher) void {
        for(sb.batch[0..sb.sprite_count]) |spr, i| {
            const vindex = i * single_sprite_vertices;
            sb.vbuf[vindex] = .{
                
            };
        }

        sb.sprite_count = 0;
    }

    pub fn drawSprite(sb: *SpriteBatcher, spr: *Sprite) void {
        // update buffer
        sg.updateBuffer(sb.bind.vertex_buffers[0], sg.asRange(sb.vbuf));

        // set texture
        sb.bind.fs_images[shader.SLOT_tex].id = spr.texture.getId();
        
        // 2d camera matrix
        // s = scale
        // o = rotation? (probably set to 0 for now)
        // t = translation
        // [ sx ox tx ]
        // [ oy sy ty ]
        // [  0  0  1 ]

        sg.beginDefaultPass(sb.pass_action, app.width(), app.height());
        sg.applyPipeline(sb.pip);
        sg.applyBindings(sb.bind);
        sg.draw(0, vertices.len, 1);
        sg.endPass();
        sg.commit();
    }
};