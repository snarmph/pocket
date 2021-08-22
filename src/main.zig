// const std = @import("std");
// const print = std.log.info;

// // const sokol = @import("sokol");
// const sokol = @import("sokol/sokol.zig");
// const app   = sokol.app;
// const sg    = sokol.gfx;
// const sgapp = sokol.app_gfx_glue;
// const time  = sokol.time;

// const gfx = @import("gfx.zig");
// // usingnamespace @import("math.zig");

// const SpriteBatcher = @import("sprite_batcher.zig").SpriteBatcher;
// // const shader = @import("default.glsl.zig");

// const state = struct {
//     var bind: sg.Bindings = .{};
//     var pip: sg.Pipeline = .{};
//     var pass_action: sg.PassAction = .{};
//     // const view = Mat4.lookat(.{ .x=0.0, .y=1.5, .z=6.0 }, Vec3.zero(), Vec3.up());
//     var batch: SpriteBatcher = .{
//         .allocator = std.testing.allocator
//     };
//     // var rx: f32 = 0;
//     // var ry: f32 = 0;
// };

// export fn init() void {
//     sg.setup(.{
//         .context = sgapp.context()
//     });
//     time.setup();

//     const vertices = [_]gfx.Vertex {
//         // pos                         color              texcoords
//         .{ .x=-1.0, .y=-1.0, .z=-1.0,  .color=0xFF0000FF, .u=    0, .v=    0 },
//         .{ .x= 1.0, .y=-1.0, .z=-1.0,  .color=0xFF0000FF, .u=32767, .v=    0 },
//         .{ .x= 1.0, .y= 1.0, .z=-1.0,  .color=0xFF0000FF, .u=32767, .v=32767 },
//         .{ .x=-1.0, .y= 1.0, .z=-1.0,  .color=0xFF0000FF, .u=    0, .v=32767 },

//         .{ .x=-1.0, .y=-1.0, .z= 1.0,  .color=0xFF00FF00, .u=    0, .v=    0 },
//         .{ .x= 1.0, .y=-1.0, .z= 1.0,  .color=0xFF00FF00, .u=32767, .v=    0 },
//         .{ .x= 1.0, .y= 1.0, .z= 1.0,  .color=0xFF00FF00, .u=32767, .v=32767 },
//         .{ .x=-1.0, .y= 1.0, .z= 1.0,  .color=0xFF00FF00, .u=    0, .v=32767 },

//         .{ .x=-1.0, .y=-1.0, .z=-1.0,  .color=0xFFFF0000, .u=    0, .v=    0 },
//         .{ .x=-1.0, .y= 1.0, .z=-1.0,  .color=0xFFFF0000, .u=32767, .v=    0 },
//         .{ .x=-1.0, .y= 1.0, .z= 1.0,  .color=0xFFFF0000, .u=32767, .v=32767 },
//         .{ .x=-1.0, .y=-1.0, .z= 1.0,  .color=0xFFFF0000, .u=    0, .v=32767 },

//         .{ .x= 1.0, .y=-1.0, .z=-1.0,  .color=0xFFFF007F, .u=    0, .v=    0 },
//         .{ .x= 1.0, .y= 1.0, .z=-1.0,  .color=0xFFFF007F, .u=32767, .v=    0 },
//         .{ .x= 1.0, .y= 1.0, .z= 1.0,  .color=0xFFFF007F, .u=32767, .v=32767 },
//         .{ .x= 1.0, .y=-1.0, .z= 1.0,  .color=0xFFFF007F, .u=    0, .v=32767 },

//         .{ .x=-1.0, .y=-1.0, .z=-1.0,  .color=0xFFFF7F00, .u=    0, .v=    0 },
//         .{ .x=-1.0, .y=-1.0, .z= 1.0,  .color=0xFFFF7F00, .u=32767, .v=    0 },
//         .{ .x= 1.0, .y=-1.0, .z= 1.0,  .color=0xFFFF7F00, .u=32767, .v=32767 },
//         .{ .x= 1.0, .y=-1.0, .z=-1.0,  .color=0xFFFF7F00, .u=    0, .v=32767 },

//         .{ .x=-1.0, .y= 1.0, .z=-1.0,  .color=0xFF007FFF, .u=    0, .v=    0 },
//         .{ .x=-1.0, .y= 1.0, .z= 1.0,  .color=0xFF007FFF, .u=32767, .v=    0 },
//         .{ .x= 1.0, .y= 1.0, .z= 1.0,  .color=0xFF007FFF, .u=32767, .v=32767 },
//         .{ .x= 1.0, .y= 1.0, .z=-1.0,  .color=0xFF007FFF, .u=    0, .v=32767 },
//     };
    
//     state.bind.vertex_buffers[0] = sg.makeBuffer(.{
//         .data = sg.asRange(vertices)
//     });

//     // cube index buffer
//     const indices = [_]u16 {
//         0, 1, 2,  0, 2, 3,
//         6, 5, 4,  7, 6, 4,
//         8, 9, 10,  8, 10, 11,
//         14, 13, 12,  15, 14, 12,
//         16, 17, 18,  16, 18, 19,
//         22, 21, 20,  23, 22, 20
//     };

//     state.bind.index_buffer = sg.makeBuffer(.{
//         .type = .INDEXBUFFER,
//         .data = sg.asRange(indices)
//     });

//      // create a small checker-board texture
//     const pixels = [4*4]u32 {
//         0xFFFFFFFF, 0xFF000000, 0xFFFFFFFF, 0xFF000000,
//         0xFF000000, 0xFFFFFFFF, 0xFF000000, 0xFFFFFFFF,
//         0xFFFFFFFF, 0xFF000000, 0xFFFFFFFF, 0xFF000000,
//         0xFF000000, 0xFFFFFFFF, 0xFF000000, 0xFFFFFFFF,
//     };

//     var img_desc: sg.ImageDesc = .{
//         .width = 4,
//         .height = 4,
//     };
//     img_desc.data.subimage[0][0] = sg.asRange(pixels);
//     state.bind.fs_images[shader.SLOT_tex] = sg.makeImage(img_desc);

//     var pip_desc: sg.PipelineDesc = .{
//         .shader = sg.makeShader(shader.texcubeShaderDesc(sg.queryBackend())),
//         .index_type = .UINT16,
//         .depth = .{
//             .compare = .LESS_EQUAL,
//             .write_enabled = true,
//         },
//         .cull_mode = .BACK
//     };
//     pip_desc.layout.attrs[shader.ATTR_vs_pos].format = .FLOAT3;
//     pip_desc.layout.attrs[shader.ATTR_vs_color0].format = .UBYTE4N;
//     pip_desc.layout.attrs[shader.ATTR_vs_texcoord0].format = .SHORT2N;
//     state.pip = sg.makePipeline(pip_desc);
    
//     // pass action for clearing the frame buffer
//     state.pass_action.colors[0] = .{ .action = .CLEAR, .value = .{ .r=0.25, .g=0.5, .b=0.75, .a=1 } };
// }

// export fn frame() void {
//     sg.beginDefaultPass(.{}, app.width(), app.height());
//     sg.applyPipeline(state.pip);
//     sg.applyBindings(state.bind);
//     // sg.applyUniforms(.VS, shader.SLOT_vs_params, sg.asRange(vs_params));
//     // sg.draw(0, 36, 1);
//     sg.endPass();
//     sg.commit();
// }

// export fn event(ev: [*c]const app.Event) void {
//     if(ev != null) {
//         const e = ev.*;
//         _ = e;
//         // print("event: {}", .{e.type});
//     }
// }

// export fn cleanup() void {
//     sg.shutdown();
// }

// pub fn main() anyerror!void {
//     app.run(.{
//         .init_cb = init,
//         .frame_cb = frame,
//         .event_cb = event,
//         .cleanup_cb = cleanup,
//         .width = 640,
//         .height = 480,
//         .icon = .{
//             .sokol_default = true
//         },
//         .window_title = "pocket"
//     });
// }

const std = @import("std");
const err   = std.log.err;
const warn  = std.log.warn;
const info  = std.log.info;
const debug = std.log.debug;
const pretty = @import("prettyprint.zig");

const sokol = @import("sokol/sokol.zig");
const app   = sokol.app;

const Core = @import("core.zig").Core;
const Texture = @import("texture.zig").Texture;
usingnamespace @import("sprite_batcher.zig");

const stb = @import("stb/stb.zig");

const GpaType = std.heap.GeneralPurposeAllocator(.{});
var gpa = GpaType{};
var batch: SpriteBatcher = undefined;
var txt: Texture = undefined;

pub fn log(
    comptime level: std.log.Level,
    comptime scope: @TypeOf(.EnumLiteral),
    comptime format: []const u8,
    args: anytype
) void {
    pretty.log(level, scope, format, args);
}

pub fn main() !void {
    std.log.notice("test: {}", .{12});
    Core.run(.{
        .init_fn    = init,
        .frame_fn   = frame,
        .event_fn   = event,
        .cleanup_fn = cleanup,
        .width      = 500,
        .height     = 500,
        .title      = "pocket zig"
    });
}

fn init() !void {
    txt = try Texture.load("data/red.png");

    batch = .{ .allocator = &gpa.allocator };
    batch.init();
}

fn frame() !void {
    batch.drawSprite(&.{
        .texture = txt,
    });
}

fn event(e: *const app.Event) !void {
    _ = e;
}

fn cleanup() !void {
    txt.destroy();

    if(gpa.deinit()) {
        err("Leaks found", .{});
        return error.MemoryLeak;
    }
}