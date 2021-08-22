const string = []const u8;
const std = @import("std");

const Level = enum {
    err, warn, info, success
};

pub fn print(comptime fmt: string, args: anytype) void {
    const stderr = std.io.getStdErr().writer();
    const held = std.debug.getStderrMutex().acquire();
    defer held.release();

    nosuspend stderr.print(comptime prettyFmt(fmt, true), args) catch return;
}

pub fn println(comptime fmt: string, args: anytype) void {
    print(fmt ++ "\n", args);
}

pub fn log(
    comptime message_level: std.log.Level,
    comptime scope: @TypeOf(.EnumLiteral),
    comptime fmt: string,
    args: anytype
) void {
    const level_txt = switch (message_level) {
        .emerg   => "<magenta>[EMERG]",
        .alert   => "<red>[ALERT]",
        .crit    => "<red>[CRIT]",
        .err    => "<red>[ERROR]",
        .warn   => "<yellow>[WARNING]",
        .notice => "<green>[NOTICE]",
        .info   => "[INFO]",
        .debug  => "<blue>[DEBUG]",
    };
    const prefix2 = if (scope == .default) ": " else "(" ++ @tagName(scope) ++ "): ";
    println("<b>" ++ level_txt ++ prefix2 ++ "<r>" ++ fmt, args);
}

// Valid colors:
// <black>
// <blue>
// <cyan>
// <green>
// <magenta>
// <red>
// <white>
// <yellow>
// <b> - bold
// <d> - dim
// </r> - reset
// <r> - reset
pub fn prettyFmt(comptime fmt: string, comptime is_enabled: bool) string {
    comptime var new_fmt: [fmt.len * 4]u8 = undefined;
    comptime var new_fmt_i: usize = 0;
    const ED = comptime "\x1b[";

    @setEvalBranchQuota(9999);
    comptime var i: usize = 0;
    comptime while (i < fmt.len) {
        const c = fmt[i];
        switch (c) {
            '\\' => {
                i += 1;
                if (fmt.len < i) {
                    switch (fmt[i]) {
                        '<', '>' => {
                            i += 1;
                        },
                        else => {
                            new_fmt[new_fmt_i] = '\\';
                            new_fmt_i += 1;
                            new_fmt[new_fmt_i] = fmt[i];
                            new_fmt_i += 1;
                        },
                    }
                }
            },
            '>' => {
                i += 1;
            },
            '{' => {
                while (fmt.len > i and fmt[i] != '}') {
                    new_fmt[new_fmt_i] = fmt[i];
                    new_fmt_i += 1;
                    i += 1;
                }
            },
            '<' => {
                i += 1;
                var is_reset = fmt[i] == '/';
                if (is_reset) i += 1;
                var start: usize = i;
                while (i < fmt.len and fmt[i] != '>') {
                    i += 1;
                }

                const color_name = fmt[start..i];
                const color_str = color_picker: {
                    if (std.mem.eql(u8, color_name, "black")) {
                        break :color_picker ED ++ "30m";
                    } else if (std.mem.eql(u8, color_name, "blue")) {
                        break :color_picker ED ++ "34m";
                    } else if (std.mem.eql(u8, color_name, "b")) {
                        break :color_picker ED ++ "1m";
                    } else if (std.mem.eql(u8, color_name, "d")) {
                        break :color_picker ED ++ "2m";
                    } else if (std.mem.eql(u8, color_name, "cyan")) {
                        break :color_picker ED ++ "36m";
                    } else if (std.mem.eql(u8, color_name, "green")) {
                        break :color_picker ED ++ "32m";
                    } else if (std.mem.eql(u8, color_name, "magenta")) {
                        break :color_picker ED ++ "35m";
                    } else if (std.mem.eql(u8, color_name, "red")) {
                        break :color_picker ED ++ "31m";
                    } else if (std.mem.eql(u8, color_name, "white")) {
                        break :color_picker ED ++ "37m";
                    } else if (std.mem.eql(u8, color_name, "yellow")) {
                        break :color_picker ED ++ "33m";
                    } else if (std.mem.eql(u8, color_name, "r")) {
                        is_reset = true;
                        break :color_picker "";
                    } else {
                        @compileError("Invalid color name passed: " ++ color_name);
                    }
                };
                var orig = new_fmt_i;

                if (is_enabled) {
                    if (!is_reset) {
                        orig = new_fmt_i;
                        new_fmt_i += color_str.len;
                        std.mem.copy(u8, new_fmt[orig..new_fmt_i], color_str);
                    }

                    if (is_reset) {
                        const reset_sequence = "\x1b[0m";
                        orig = new_fmt_i;
                        new_fmt_i += reset_sequence.len;
                        std.mem.copy(u8, new_fmt[orig..new_fmt_i], reset_sequence);
                    }
                }
            },

            else => {
                new_fmt[new_fmt_i] = fmt[i];
                new_fmt_i += 1;
                i += 1;
            },
        }
    };

    return comptime new_fmt[0..new_fmt_i];
}