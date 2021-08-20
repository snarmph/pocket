const Allocator = @import("std").mem.Allocator;
usingnamespace @import("math.zig");

const tile_sz: f32 = 16.0;

pub const Sprite = struct {
    pos: Vec2 = Vec2.zero(),
    size: Vec2 = Vec2.new(tile_sz, tile_sz),
    scale: Vec2 = Vec2.one(),
    texc: Vec2 = Vec2.zero(),
    texsize: Vec2 = Vec2.one(),
    rotation: f32 = 0.0,
};

pub const SpriteBatcher = struct {
    allocator: *Allocator,

    // pub fn addSprite(self: *SpriteBatcher) void {

    // }
};