const Vec2 = @import("math.zig").Vec2;
const Vec3 = @import("math.zig").Vec3;

pub const Vertex = packed struct {
    x: f32, y: f32, z: f32,
    color: u32,
    u: f32, v: f32,
};