const std = @import("std");
const Builder = std.build.Builder;
const LibExeObjStep = std.build.LibExeObjStep;
const Pkg = std.build.Pkg;
const CrossTarget = std.zig.CrossTarget;
const Mode = std.builtin.Mode;

const addCLibs = @import("clibs.zig").addCLibs;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("pocket", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    addCLibs(exe, b, target, mode);
    exe.addIncludeDir(".");
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}