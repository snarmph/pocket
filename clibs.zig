const std = @import("std");
const Builder = std.build.Builder;
const LibExeObjStep = std.build.LibExeObjStep;
const Pkg = std.build.Pkg;
const CrossTarget = std.zig.CrossTarget;
const Mode = std.builtin.Mode;
const string = []const u8;

const pkg_sokol = Pkg {
    .name = "sokol",
    .path = .{ .path = "src/sokol/sokol.zig" },
};

const pkg_stb = Pkg {
    .name = "stb",
    .path = .{ .path = "src/stb/stb.zig" },
};

pub fn addCLibs(
    exe: *LibExeObjStep,
    b: *Builder, 
    target: CrossTarget, 
    mode: Mode, 
) void {
    const sokol = buildSokol(b, target, mode);
    const stb = buildStb(b, target, mode);

    exe.linkLibC();
    exe.addPackage(pkg_sokol);    
    exe.addPackage(pkg_stb);  

    exe.linkLibrary(sokol);
    exe.linkLibrary(stb);  
}

fn buildSokol(b: *Builder, target: CrossTarget, mode: Mode) *LibExeObjStep {
    const lib = b.addStaticLibrary("sokol", null);
    lib.setTarget(target);
    lib.setBuildMode(mode);
    lib.linkLibC();
    const sokol_path = "src/sokol/c/";
    const csources = [_][]const u8 {
        "sokol_app.c",
        "sokol_gfx.c",
        "sokol_time.c",
        "sokol_audio.c",
    };
     if (lib.target.isDarwin()) {
        b.env_map.put("ZIG_SYSTEM_LINKER_HACK", "1") catch unreachable;
        inline for (csources) |csrc| {
            lib.addCSourceFile(sokol_path ++ csrc, &[_][]const u8{"-ObjC", "-DIMPL"});
        }
        lib.linkFramework("MetalKit");
        lib.linkFramework("Metal");
        lib.linkFramework("Cocoa");
        lib.linkFramework("QuartzCore");
        lib.linkFramework("AudioToolbox");
    } else {
        inline for (csources) |csrc| {
            lib.addCSourceFile(sokol_path ++ csrc, &[_][]const u8{"-DIMPL"});
        }
        if (lib.target.isLinux()) {
            lib.linkSystemLibrary("X11");
            lib.linkSystemLibrary("Xi");
            lib.linkSystemLibrary("Xcursor");
            lib.linkSystemLibrary("GL");
            lib.linkSystemLibrary("asound");
        }
        else if (lib.target.isWindows()) {
            lib.linkSystemLibrary("kernel32");
            lib.linkSystemLibrary("user32");
            lib.linkSystemLibrary("gdi32");
            lib.linkSystemLibrary("ole32");
            lib.linkSystemLibrary("d3d11");
            lib.linkSystemLibrary("dxgi");
        }
    }
    return lib;
}

fn buildStb(b: *Builder, target: CrossTarget, mode: Mode) *LibExeObjStep {
    const lib = b.addStaticLibrary("stb", null);
    lib.setTarget(target);
    lib.setBuildMode(mode);
    lib.linkLibC();

    const stb_path = "src/stb/c/";

    lib.addCSourceFile(
        stb_path ++ "stb.c", 
        &[_][]const u8{
            "-std=c99"
        }
    );

    return lib;
}
