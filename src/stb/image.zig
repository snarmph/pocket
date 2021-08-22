const std = @import("std");

extern fn stbi_load(filename: [*c]const u8, x: [*c]i32, y: [*c]i32, channels_in_file: [*c]i32, desired_channels: i32) [*c]u8;
extern fn stbi_image_free(retval_from_stbi_load: *c_void) void;

pub const Image = struct {
    data: []u8,
    x: i32,
    y: i32, 
    channels: i32,

    pub fn load(
        filename: []const u8,  
        desired_channels: i32
    ) !Image {
        var self: Image = undefined;
        const data = stbi_load(
            @ptrCast([*c]const u8, filename), 
            &self.x, &self.y, 
            &self.channels, 
            desired_channels
        );
        if(data == null) {
            std.log.err("couldn't load image {s}", .{filename});
            return error.CouldntLoadImage;
        }
        const sz = self.getLength();
        self.data = data[0..sz];
        std.log.notice("loaded {s}", .{filename});
        return self;
    }

    pub fn free(self: *Image) void {
        stbi_image_free(self.data.ptr);
    }

    pub fn getLength(self: *Image) usize {
        return @intCast(usize, self.x * self.y * self.channels);
    }
};