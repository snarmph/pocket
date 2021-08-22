const std = @import("std");
const stbi = @import("stb").image;
const sg = @import("sokol/sokol.zig").gfx;

pub const Texture = struct {
    id: sg.Image = .{},

    pub fn load(filename: []const u8) !Texture {
        var img = try stbi.Image.load(filename, 4);
        defer img.free();

        var desc = sg.ImageDesc {
            .width = img.x,
            .height = img.y,
            .pixel_format = .RGBA8,
        };
        desc.data.subimage[0][0] = sg.asRange(img.data);
        
        var tex: Texture = .{ .id = sg.makeImage(desc) };
        if(!tex.isValid()) {
            std.log.err("failed to load texture {s}", .{filename});
            return error.CouldntLoadTexture;
        }
        
        return tex;
    }

    pub fn destroy(self: *Texture) void {
        sg.destroyImage(self.id);
    }

    pub fn isValid(self: *Texture) bool {
        return self.getId() != sg.invalid_id;
    }

    pub fn getId(self: *Texture) u32 {
        return self.id.id;
    }
};