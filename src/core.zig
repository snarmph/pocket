const std = @import("std");
usingnamespace @import("prettyprint.zig");

const sokol = @import("sokol");
const app   = sokol.app;
const sg    = sokol.gfx;
const sgapp = sokol.app_gfx_glue;
const time  = sokol.time;

const CallbackFn = fn() anyerror!void;
const EventCallbackFn = fn(e: *const app.Event) anyerror!void;

const CoreDesc = struct {
    init_fn: CallbackFn,
    frame_fn: CallbackFn,
    event_fn: EventCallbackFn,
    cleanup_fn: CallbackFn,
    width: i32,
    height: i32,
    title: []const u8
};

pub const Core = struct {
    var options: CoreDesc = undefined;

    pub fn run(desc: CoreDesc) void {
        Core.options = desc;

        app.run(.{
            .init_cb    = init,
            .frame_cb   = frame,
            .event_cb   = event,
            .cleanup_cb = cleanup,
            .width  = desc.width,
            .height = desc.height,
            .window_title = @ptrCast([*c]const u8, desc.title),
        });
    }

    fn init() callconv(.C) void {
        sg.setup(.{
            .context = sgapp.context()
        });
        time.setup();
        
        options.init_fn() catch |e| {
            err("{}", .{e});
            std.c.exit(1);
            // @panic("error encountered during init, panicking");
        };
        success("initialized successfully", .{});
    }

    fn frame() callconv(.C) void {
        options.frame_fn() catch |e| {
            err("{}", .{e});
            std.c.exit(1);
        };
    }

    fn event(ev: [*c]const app.Event) callconv(.C) void {
        options.event_fn(ev) catch |e| {
            err("{}", .{e});
            std.c.exit(1);
        };
    }

    fn cleanup() callconv(.C) void {
        options.cleanup_fn() catch |e| {
            err("{}", .{e});
            std.c.exit(1);
        };

        sg.shutdown();

        success("cleaned up successfully", .{});
    }
};