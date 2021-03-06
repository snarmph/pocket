pub usingnamespace @import("std").zig.c_builtins;
pub const struct_spritebatch_sprite_t = extern struct {
    image_id: c_ulonglong,
    texture_id: c_ulonglong,
    w: c_int,
    h: c_int,
    x: f32,
    y: f32,
    sx: f32,
    sy: f32,
    c: f32,
    s: f32,
    minx: f32,
    miny: f32,
    maxx: f32,
    maxy: f32,
    sort_bits: c_int,
};
pub const spritebatch_sprite_t = struct_spritebatch_sprite_t;
pub const struct_hashtable_internal_slot_t = extern struct {
    key_hash: c_uint,
    item_index: c_int,
    base_count: c_int,
};
pub const struct_hashtable_t = extern struct {
    memctx: ?*c_void,
    count: c_int,
    item_size: c_int,
    slots: [*c]struct_hashtable_internal_slot_t,
    slot_capacity: c_int,
    items_key: [*c]c_ulonglong,
    items_slot: [*c]c_int,
    items_data: ?*c_void,
    item_capacity: c_int,
    swap_temp: ?*c_void,
};
pub const hashtable_t = struct_hashtable_t;
pub const struct_spritebatch_internal_atlas_t = extern struct {
    texture_id: c_ulonglong,
    volume_ratio: f32,
    sprites_to_textures: hashtable_t,
    next: [*c]struct_spritebatch_internal_atlas_t,
    prev: [*c]struct_spritebatch_internal_atlas_t,
};
pub const spritebatch_internal_atlas_t = struct_spritebatch_internal_atlas_t;
pub const submit_batch_fn = fn ([*c]spritebatch_sprite_t, c_int, c_int, c_int, ?*c_void) callconv(.C) void;
pub const get_pixels_fn = fn (c_ulonglong, ?*c_void, c_int, ?*c_void) callconv(.C) void;
pub const generate_texture_handle_fn = fn (?*c_void, c_int, c_int, ?*c_void) callconv(.C) c_ulonglong;
pub const destroy_texture_handle_fn = fn (c_ulonglong, ?*c_void) callconv(.C) void;
pub const sprites_sorter_fn = fn ([*c]spritebatch_sprite_t, c_int) callconv(.C) void;
pub const struct_spritebatch_t = extern struct {
    input_count: c_int,
    input_capacity: c_int,
    input_buffer: [*c]spritebatch_internal_sprite_t,
    sprite_count: c_int,
    sprite_capacity: c_int,
    sprites: [*c]spritebatch_sprite_t,
    sprites_scratch: [*c]spritebatch_sprite_t,
    key_buffer_count: c_int,
    key_buffer_capacity: c_int,
    key_buffer: [*c]c_ulonglong,
    pixel_buffer_size: c_int,
    pixel_buffer: ?*c_void,
    sprites_to_lonely_textures: hashtable_t,
    sprites_to_atlases: hashtable_t,
    atlases: [*c]spritebatch_internal_atlas_t,
    pixel_stride: c_int,
    atlas_width_in_pixels: c_int,
    atlas_height_in_pixels: c_int,
    atlas_use_border_pixels: c_int,
    ticks_to_decay_texture: c_int,
    lonely_buffer_count_till_flush: c_int,
    lonely_buffer_count_till_decay: c_int,
    ratio_to_decay_atlas: f32,
    ratio_to_merge_atlases: f32,
    batch_callback: ?submit_batch_fn,
    get_pixels_callback: ?get_pixels_fn,
    generate_texture_callback: ?generate_texture_handle_fn,
    delete_texture_callback: ?destroy_texture_handle_fn,
    sprites_sorter_callback: ?sprites_sorter_fn,
    mem_ctx: ?*c_void,
    udata: ?*c_void,
};
pub const spritebatch_t = struct_spritebatch_t;
pub const struct_spritebatch_config_t = extern struct {
    pixel_stride: c_int,
    atlas_width_in_pixels: c_int,
    atlas_height_in_pixels: c_int,
    atlas_use_border_pixels: c_int,
    ticks_to_decay_texture: c_int,
    lonely_buffer_count_till_flush: c_int,
    ratio_to_decay_atlas: f32,
    ratio_to_merge_atlases: f32,
    batch_callback: ?submit_batch_fn,
    get_pixels_callback: ?get_pixels_fn,
    generate_texture_callback: ?generate_texture_handle_fn,
    delete_texture_callback: ?destroy_texture_handle_fn,
    sprites_sorter_callback: ?sprites_sorter_fn,
    allocator_context: ?*c_void,
};
pub const spritebatch_config_t = struct_spritebatch_config_t;
pub export fn spritebatch_push(arg_sb: [*c]spritebatch_t, arg_sprite: spritebatch_sprite_t) c_int {
    var sb = arg_sb;
    var sprite = arg_sprite;
    _ = @as(c_int, 0);
    _ = @as(c_int, 0);
    {
        if (sb.*.input_count == sb.*.input_capacity) {
            var new_capacity: c_int = sb.*.input_capacity * @as(c_int, 2);
            var new_data: ?*c_void = malloc(@sizeOf(spritebatch_internal_sprite_t) *% @bitCast(c_ulonglong, @as(c_longlong, new_capacity)));
            if (!(new_data != null)) return 0;
            _ = memcpy(new_data, @ptrCast(?*const c_void, sb.*.input_buffer), @sizeOf(spritebatch_internal_sprite_t) *% @bitCast(c_ulonglong, @as(c_longlong, sb.*.input_count)));
            free(@ptrCast(?*c_void, sb.*.input_buffer));
            sb.*.input_buffer = @ptrCast([*c]spritebatch_internal_sprite_t, @alignCast(@import("std").meta.alignment(spritebatch_internal_sprite_t), new_data));
            sb.*.input_capacity = new_capacity;
        }
    }
    var sprite_out: spritebatch_internal_sprite_t = undefined;
    sprite_out.image_id = sprite.image_id;
    sprite_out.sort_bits = sprite.sort_bits;
    sprite_out.w = sprite.w;
    sprite_out.h = sprite.h;
    sprite_out.x = sprite.x;
    sprite_out.y = sprite.y;
    sprite_out.sx = sprite.sx + (if (sb.*.atlas_use_border_pixels != 0) (sprite.sx / @intToFloat(f32, sprite.w)) * 2.0 else @intToFloat(f32, @as(c_int, 0)));
    sprite_out.sy = sprite.sy + (if (sb.*.atlas_use_border_pixels != 0) (sprite.sy / @intToFloat(f32, sprite.h)) * 2.0 else @intToFloat(f32, @as(c_int, 0)));
    sprite_out.c = sprite.c;
    sprite_out.s = sprite.s;
    (blk: {
        const tmp = blk_1: {
            const ref = &sb.*.input_count;
            const tmp_2 = ref.*;
            ref.* += 1;
            break :blk_1 tmp_2;
        };
        if (tmp >= 0) break :blk sb.*.input_buffer + @intCast(usize, tmp) else break :blk sb.*.input_buffer - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
    }).* = sprite_out;
    return 1;
}
pub export fn spritebatch_prefetch(arg_sb: [*c]spritebatch_t, arg_image_id: c_ulonglong, arg_w: c_int, arg_h: c_int) void {
    var sb = arg_sb;
    var image_id = arg_image_id;
    var w = arg_w;
    var h = arg_h;
    var atlas_ptr: ?*c_void = hashtable_find(&sb.*.sprites_to_atlases, image_id);
    if (!(atlas_ptr != null)) {
        _ = spritebatch_internal_lonely_sprite(sb, image_id, w, h, null, @as(c_int, 0));
    }
}
pub export fn spritebatch_tick(arg_sb: [*c]spritebatch_t) void {
    var sb = arg_sb;
    var atlas: [*c]spritebatch_internal_atlas_t = sb.*.atlases;
    if (atlas != null) {
        var sentinel: [*c]spritebatch_internal_atlas_t = atlas;
        while (true) {
            var texture_count: c_int = hashtable_count(&atlas.*.sprites_to_textures);
            var textures: [*c]spritebatch_internal_texture_t = @ptrCast([*c]spritebatch_internal_texture_t, @alignCast(@import("std").meta.alignment(spritebatch_internal_texture_t), hashtable_items(&atlas.*.sprites_to_textures)));
            {
                var i: c_int = 0;
                while (i < texture_count) : (i += 1) {
                    (blk: {
                        const tmp = i;
                        if (tmp >= 0) break :blk textures + @intCast(usize, tmp) else break :blk textures - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
                    }).*.timestamp += @as(c_int, 1);
                }
            }
            atlas = atlas.*.next;
            if (!(atlas != sentinel)) break;
        }
    }
    var texture_count: c_int = hashtable_count(&sb.*.sprites_to_lonely_textures);
    var lonely_textures: [*c]spritebatch_internal_lonely_texture_t = @ptrCast([*c]spritebatch_internal_lonely_texture_t, @alignCast(@import("std").meta.alignment(spritebatch_internal_lonely_texture_t), hashtable_items(&sb.*.sprites_to_lonely_textures)));
    {
        var i: c_int = 0;
        while (i < texture_count) : (i += 1) {
            (blk: {
                const tmp = i;
                if (tmp >= 0) break :blk lonely_textures + @intCast(usize, tmp) else break :blk lonely_textures - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
            }).*.timestamp += @as(c_int, 1);
        }
    }
}
pub export fn spritebatch_flush(arg_sb: [*c]spritebatch_t) c_int {
    var sb = arg_sb;
    spritebatch_internal_process_input(sb, @as(c_int, 0));
    var texture_count: c_int = hashtable_count(&sb.*.sprites_to_lonely_textures);
    var lonely_textures: [*c]spritebatch_internal_lonely_texture_t = @ptrCast([*c]spritebatch_internal_lonely_texture_t, @alignCast(@import("std").meta.alignment(spritebatch_internal_lonely_texture_t), hashtable_items(&sb.*.sprites_to_lonely_textures)));
    {
        var i: c_int = 0;
        while (i < texture_count) : (i += 1) {
            var lonely: [*c]spritebatch_internal_lonely_texture_t = lonely_textures + @bitCast(usize, @intCast(isize, i));
            if (lonely.*.texture_id == @bitCast(c_ulonglong, @as(c_longlong, ~@as(c_int, 0)))) {
                lonely.*.texture_id = spritebatch_internal_generate_texture_handle(sb, lonely.*.image_id, lonely.*.w, lonely.*.h);
            }
        }
    }
    spritebatch_internal_sort_sprites(sb);
    var min: c_int = 0;
    var max: c_int = 0;
    var done: c_int = @boolToInt(!(sb.*.sprite_count != 0));
    var count: c_int = 0;
    while (!(done != 0)) {
        var id: c_ulonglong = (blk: {
            const tmp = min;
            if (tmp >= 0) break :blk sb.*.sprites + @intCast(usize, tmp) else break :blk sb.*.sprites - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
        }).*.texture_id;
        var image_id: c_ulonglong = (blk: {
            const tmp = min;
            if (tmp >= 0) break :blk sb.*.sprites + @intCast(usize, tmp) else break :blk sb.*.sprites - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
        }).*.image_id;
        while (true) {
            if (max == sb.*.sprite_count) {
                done = 1;
                break;
            }
            if (id != (blk: {
                const tmp = max;
                if (tmp >= 0) break :blk sb.*.sprites + @intCast(usize, tmp) else break :blk sb.*.sprites - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
            }).*.texture_id) break;
            max += 1;
        }
        var batch_count: c_int = max - min;
        if (batch_count != 0) {
            var atlas_ptr: ?*c_void = hashtable_find(&sb.*.sprites_to_atlases, image_id);
            var w: c_int = undefined;
            var h: c_int = undefined;
            if (atlas_ptr != null) {
                w = sb.*.atlas_width_in_pixels;
                h = sb.*.atlas_height_in_pixels;
            } else {
                var tex: [*c]spritebatch_internal_lonely_texture_t = @ptrCast([*c]spritebatch_internal_lonely_texture_t, @alignCast(@import("std").meta.alignment(spritebatch_internal_lonely_texture_t), hashtable_find(&sb.*.sprites_to_lonely_textures, image_id)));
                _ = @as(c_int, 0);
                w = tex.*.w;
                h = tex.*.h;
                if (sb.*.atlas_use_border_pixels != 0) {
                    w += @as(c_int, 2);
                    h += @as(c_int, 2);
                }
            }
            sb.*.batch_callback.?(sb.*.sprites + @bitCast(usize, @intCast(isize, min)), batch_count, w, h, sb.*.udata);
            count += 1;
        }
        min = max;
    }
    sb.*.sprite_count = 0;
    if (count > @as(c_int, 1)) {}
    return count;
}
pub export fn spritebatch_defrag(arg_sb: [*c]spritebatch_t) c_int {
    var sb = arg_sb;
    var ticks_to_decay_texture: c_int = sb.*.ticks_to_decay_texture;
    var ratio_to_decay_atlas: f32 = sb.*.ratio_to_decay_atlas;
    var atlas: [*c]spritebatch_internal_atlas_t = sb.*.atlases;
    if (atlas != null) {
        spritebatch_internal_log_chain(atlas);
        var sentinel: [*c]spritebatch_internal_atlas_t = atlas;
        while (true) {
            var next: [*c]spritebatch_internal_atlas_t = atlas.*.next;
            var texture_count: c_int = hashtable_count(&atlas.*.sprites_to_textures);
            var textures: [*c]spritebatch_internal_texture_t = @ptrCast([*c]spritebatch_internal_texture_t, @alignCast(@import("std").meta.alignment(spritebatch_internal_texture_t), hashtable_items(&atlas.*.sprites_to_textures)));
            var decayed_texture_count: c_int = 0;
            {
                var i: c_int = 0;
                while (i < texture_count) : (i += 1) if ((blk: {
                    const tmp = i;
                    if (tmp >= 0) break :blk textures + @intCast(usize, tmp) else break :blk textures - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
                }).*.timestamp >= ticks_to_decay_texture) {
                    decayed_texture_count += 1;
                };
            }
            var ratio: f32 = undefined;
            if (!(decayed_texture_count != 0)) {
                ratio = 0;
            } else {
                ratio = @intToFloat(f32, texture_count) / @intToFloat(f32, decayed_texture_count);
            }
            if (ratio > ratio_to_decay_atlas) {
                spritebatch_internal_flush_atlas(sb, atlas, &sentinel, &next);
            }
            atlas = next;
            if (!(atlas != sentinel)) break;
        }
    }
    var ratio_to_merge_atlases: f32 = sb.*.ratio_to_merge_atlases;
    atlas = sb.*.atlases;
    if (atlas != null) {
        var sp: c_int = 0;
        var merge_stack: [2][*c]spritebatch_internal_atlas_t = undefined;
        var sentinel: [*c]spritebatch_internal_atlas_t = atlas;
        while (true) {
            var next: [*c]spritebatch_internal_atlas_t = atlas.*.next;
            _ = @as(c_int, 0);
            if (sp == @as(c_int, 2)) {
                spritebatch_internal_flush_atlas(sb, merge_stack[@intCast(c_uint, @as(c_int, 0))], &sentinel, &next);
                spritebatch_internal_flush_atlas(sb, merge_stack[@intCast(c_uint, @as(c_int, 1))], &sentinel, &next);
                sp = 0;
            }
            var ratio: f32 = atlas.*.volume_ratio;
            if (ratio < ratio_to_merge_atlases) {
                merge_stack[@intCast(c_uint, blk: {
                        const ref = &sp;
                        const tmp = ref.*;
                        ref.* += 1;
                        break :blk tmp;
                    })] = atlas;
            }
            atlas = next;
            if (!(atlas != sentinel)) break;
        }
        if (sp == @as(c_int, 2)) {
            spritebatch_internal_flush_atlas(sb, merge_stack[@intCast(c_uint, @as(c_int, 0))], null, null);
            spritebatch_internal_flush_atlas(sb, merge_stack[@intCast(c_uint, @as(c_int, 1))], null, null);
        }
    }
    var lonely_buffer_count_till_decay: c_int = sb.*.lonely_buffer_count_till_decay;
    var lonely_count: c_int = hashtable_count(&sb.*.sprites_to_lonely_textures);
    var lonely_textures: [*c]spritebatch_internal_lonely_texture_t = @ptrCast([*c]spritebatch_internal_lonely_texture_t, @alignCast(@import("std").meta.alignment(spritebatch_internal_lonely_texture_t), hashtable_items(&sb.*.sprites_to_lonely_textures)));
    if (lonely_count >= lonely_buffer_count_till_decay) {
        spritebatch_internal_qsort_lonely(&sb.*.sprites_to_lonely_textures, lonely_textures, lonely_count);
        var index: c_int = 0;
        while (true) {
            if (index == lonely_count) break;
            if ((blk: {
                const tmp = index;
                if (tmp >= 0) break :blk lonely_textures + @intCast(usize, tmp) else break :blk lonely_textures - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
            }).*.timestamp >= ticks_to_decay_texture) break;
            index += 1;
        }
        {
            var i: c_int = index;
            while (i < lonely_count) : (i += 1) {
                var texture_id: c_ulonglong = (blk: {
                    const tmp = i;
                    if (tmp >= 0) break :blk lonely_textures + @intCast(usize, tmp) else break :blk lonely_textures - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
                }).*.texture_id;
                if (texture_id != @bitCast(c_ulonglong, @as(c_longlong, ~@as(c_int, 0)))) {
                    sb.*.delete_texture_callback.?(texture_id, sb.*.udata);
                }
                _ = spritebatch_internal_buffer_key(sb, (blk: {
                    const tmp = i;
                    if (tmp >= 0) break :blk lonely_textures + @intCast(usize, tmp) else break :blk lonely_textures - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
                }).*.image_id);
            }
        }
        spritebatch_internal_remove_table_entries(sb, &sb.*.sprites_to_lonely_textures);
        lonely_count -= lonely_count - index;
        _ = @as(c_int, 0);
    }
    spritebatch_internal_process_input(sb, @as(c_int, 1));
    lonely_count = hashtable_count(&sb.*.sprites_to_lonely_textures);
    var lonely_buffer_count_till_flush: c_int = sb.*.lonely_buffer_count_till_flush;
    var stuck: c_int = 0;
    while ((lonely_count > lonely_buffer_count_till_flush) and !(stuck != 0)) {
        atlas = @ptrCast([*c]spritebatch_internal_atlas_t, @alignCast(@import("std").meta.alignment(spritebatch_internal_atlas_t), malloc(@sizeOf(spritebatch_internal_atlas_t))));
        if (sb.*.atlases != null) {
            atlas.*.prev = sb.*.atlases;
            atlas.*.next = sb.*.atlases.*.next;
            sb.*.atlases.*.next.*.prev = atlas;
            sb.*.atlases.*.next = atlas;
        } else {
            atlas.*.next = atlas;
            atlas.*.prev = atlas;
            sb.*.atlases = atlas;
        }
        spritebatch_make_atlas(sb, atlas, lonely_textures, lonely_count);
        var tex_count_in_atlas: c_int = hashtable_count(&atlas.*.sprites_to_textures);
        if (tex_count_in_atlas != lonely_count) {
            var hit_count: c_int = 0;
            {
                var i: c_int = 0;
                while (i < lonely_count) : (i += 1) {
                    var key: c_ulonglong = (blk: {
                        const tmp = i;
                        if (tmp >= 0) break :blk lonely_textures + @intCast(usize, tmp) else break :blk lonely_textures - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
                    }).*.image_id;
                    if (hashtable_find(&atlas.*.sprites_to_textures, key) != null) {
                        _ = spritebatch_internal_buffer_key(sb, key);
                        var texture_id: c_ulonglong = (blk: {
                            const tmp = i;
                            if (tmp >= 0) break :blk lonely_textures + @intCast(usize, tmp) else break :blk lonely_textures - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
                        }).*.texture_id;
                        if (texture_id != @bitCast(c_ulonglong, @as(c_longlong, ~@as(c_int, 0)))) {
                            sb.*.delete_texture_callback.?(texture_id, sb.*.udata);
                        }
                        _ = hashtable_insert(&sb.*.sprites_to_atlases, key, @ptrCast(?*const c_void, &atlas));
                    } else {
                        hit_count += 1;
                        _ = @as(c_int, 0);
                        _ = @as(c_int, 0);
                    }
                }
            }
            spritebatch_internal_remove_table_entries(sb, &sb.*.sprites_to_lonely_textures);
            lonely_count = hashtable_count(&sb.*.sprites_to_lonely_textures);
            if (!(hit_count != 0)) {
                stuck = 1;
                _ = @as(c_int, 0);
            }
        } else {
            {
                var i: c_int = 0;
                while (i < lonely_count) : (i += 1) {
                    var key: c_ulonglong = (blk: {
                        const tmp = i;
                        if (tmp >= 0) break :blk lonely_textures + @intCast(usize, tmp) else break :blk lonely_textures - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
                    }).*.image_id;
                    var texture_id: c_ulonglong = (blk: {
                        const tmp = i;
                        if (tmp >= 0) break :blk lonely_textures + @intCast(usize, tmp) else break :blk lonely_textures - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
                    }).*.texture_id;
                    if (texture_id != @bitCast(c_ulonglong, @as(c_longlong, ~@as(c_int, 0)))) {
                        sb.*.delete_texture_callback.?(texture_id, sb.*.udata);
                    }
                    _ = hashtable_insert(&sb.*.sprites_to_atlases, key, @ptrCast(?*const c_void, &atlas));
                }
            }
            hashtable_clear(&sb.*.sprites_to_lonely_textures);
            lonely_count = 0;
            break;
        }
    }
    return 1;
}
pub export fn spritebatch_init(arg_sb: [*c]spritebatch_t, arg_config: [*c]spritebatch_config_t, arg_udata: ?*c_void) c_int {
    var sb = arg_sb;
    var config = arg_config;
    var udata = arg_udata;
    if ((@boolToInt(!(config != null)) | @boolToInt(!(sb != null))) != 0) return 1;
    sb.*.pixel_stride = config.*.pixel_stride;
    sb.*.atlas_width_in_pixels = config.*.atlas_width_in_pixels;
    sb.*.atlas_height_in_pixels = config.*.atlas_height_in_pixels;
    sb.*.atlas_use_border_pixels = config.*.atlas_use_border_pixels;
    sb.*.ticks_to_decay_texture = config.*.ticks_to_decay_texture;
    sb.*.lonely_buffer_count_till_flush = config.*.lonely_buffer_count_till_flush;
    sb.*.lonely_buffer_count_till_decay = @divTrunc(sb.*.lonely_buffer_count_till_flush, @as(c_int, 2));
    if (sb.*.lonely_buffer_count_till_decay <= @as(c_int, 0)) {
        sb.*.lonely_buffer_count_till_decay = 1;
    }
    sb.*.ratio_to_decay_atlas = config.*.ratio_to_decay_atlas;
    sb.*.ratio_to_merge_atlases = config.*.ratio_to_merge_atlases;
    sb.*.batch_callback = config.*.batch_callback;
    sb.*.get_pixels_callback = config.*.get_pixels_callback;
    sb.*.generate_texture_callback = config.*.generate_texture_callback;
    sb.*.delete_texture_callback = config.*.delete_texture_callback;
    sb.*.sprites_sorter_callback = config.*.sprites_sorter_callback;
    sb.*.mem_ctx = config.*.allocator_context;
    sb.*.udata = udata;
    if ((sb.*.atlas_width_in_pixels < @as(c_int, 1)) or (sb.*.atlas_height_in_pixels < @as(c_int, 1))) return 1;
    if (sb.*.ticks_to_decay_texture < @as(c_int, 1)) return 1;
    if ((sb.*.ratio_to_decay_atlas < @intToFloat(f32, @as(c_int, 0))) or (sb.*.ratio_to_decay_atlas > 1.0)) return 1;
    if ((sb.*.ratio_to_merge_atlases < @intToFloat(f32, @as(c_int, 0))) or (sb.*.ratio_to_merge_atlases > 0.5)) return 1;
    if (!(sb.*.batch_callback != null)) return 1;
    if (!(sb.*.get_pixels_callback != null)) return 1;
    if (!(sb.*.generate_texture_callback != null)) return 1;
    if (!(sb.*.delete_texture_callback != null)) return 1;
    sb.*.input_count = 0;
    sb.*.input_capacity = 1024;
    sb.*.input_buffer = @ptrCast([*c]spritebatch_internal_sprite_t, @alignCast(@import("std").meta.alignment(spritebatch_internal_sprite_t), malloc(@sizeOf(spritebatch_internal_sprite_t) *% @bitCast(c_ulonglong, @as(c_longlong, sb.*.input_capacity)))));
    if (!(sb.*.input_buffer != null)) return 1;
    sb.*.sprite_count = 0;
    sb.*.sprite_capacity = 1024;
    sb.*.sprites = @ptrCast([*c]spritebatch_sprite_t, @alignCast(@import("std").meta.alignment(spritebatch_sprite_t), malloc(@sizeOf(spritebatch_sprite_t) *% @bitCast(c_ulonglong, @as(c_longlong, sb.*.sprite_capacity)))));
    if (sprite_batch_internal_use_scratch_buffer(sb)) {
        sb.*.sprites_scratch = @ptrCast([*c]spritebatch_sprite_t, @alignCast(@import("std").meta.alignment(spritebatch_sprite_t), malloc(@sizeOf(spritebatch_sprite_t) *% @bitCast(c_ulonglong, @as(c_longlong, sb.*.sprite_capacity)))));
    }
    if (!(sb.*.sprites != null)) return 1;
    if (sprite_batch_internal_use_scratch_buffer(sb)) {
        if (!(sb.*.sprites_scratch != null)) return 1;
    }
    sb.*.key_buffer_count = 0;
    sb.*.key_buffer_capacity = 1024;
    sb.*.key_buffer = @ptrCast([*c]c_ulonglong, @alignCast(@import("std").meta.alignment(c_ulonglong), malloc(@sizeOf(c_ulonglong) *% @bitCast(c_ulonglong, @as(c_longlong, sb.*.key_buffer_capacity)))));
    sb.*.pixel_buffer_size = 1024;
    sb.*.pixel_buffer = malloc(@bitCast(c_ulonglong, @as(c_longlong, sb.*.pixel_buffer_size * sb.*.pixel_stride)));
    hashtable_init(&sb.*.sprites_to_lonely_textures, @bitCast(c_int, @truncate(c_uint, @sizeOf(spritebatch_internal_lonely_texture_t))), @as(c_int, 1024), sb.*.mem_ctx);
    hashtable_init(&sb.*.sprites_to_atlases, @bitCast(c_int, @truncate(c_uint, @sizeOf([*c]spritebatch_internal_atlas_t))), @as(c_int, 16), sb.*.mem_ctx);
    sb.*.atlases = null;
    return 0;
}
pub export fn spritebatch_term(arg_sb: [*c]spritebatch_t) void {
    var sb = arg_sb;
    free(@ptrCast(?*c_void, sb.*.input_buffer));
    free(@ptrCast(?*c_void, sb.*.sprites));
    if (sb.*.sprites_scratch != null) {
        free(@ptrCast(?*c_void, sb.*.sprites_scratch));
    }
    free(@ptrCast(?*c_void, sb.*.key_buffer));
    free(sb.*.pixel_buffer);
    hashtable_term(&sb.*.sprites_to_lonely_textures);
    hashtable_term(&sb.*.sprites_to_atlases);
    if (sb.*.atlases != null) {
        var atlas: [*c]spritebatch_internal_atlas_t = sb.*.atlases;
        var sentinel: [*c]spritebatch_internal_atlas_t = sb.*.atlases;
        while (true) {
            hashtable_term(&atlas.*.sprites_to_textures);
            var next: [*c]spritebatch_internal_atlas_t = atlas.*.next;
            free(@ptrCast(?*c_void, atlas));
            atlas = next;
            if (!(atlas != sentinel)) break;
        }
    }
    _ = memset(@ptrCast(?*c_void, sb), @as(c_int, 0), @sizeOf(spritebatch_t));
}
pub export fn spritebatch_reset_function_ptrs(arg_sb: [*c]spritebatch_t, arg_batch_callback: ?submit_batch_fn, arg_get_pixels_callback: ?get_pixels_fn, arg_generate_texture_callback: ?generate_texture_handle_fn, arg_delete_texture_callback: ?destroy_texture_handle_fn) void {
    var sb = arg_sb;
    var batch_callback = arg_batch_callback;
    var get_pixels_callback = arg_get_pixels_callback;
    var generate_texture_callback = arg_generate_texture_callback;
    var delete_texture_callback = arg_delete_texture_callback;
    sb.*.batch_callback = batch_callback;
    sb.*.get_pixels_callback = get_pixels_callback;
    sb.*.generate_texture_callback = generate_texture_callback;
    sb.*.delete_texture_callback = delete_texture_callback;
}
pub export fn spritebatch_set_default_config(arg_config: [*c]spritebatch_config_t) void {
    var config = arg_config;
    config.*.pixel_stride = @bitCast(c_int, @truncate(c_uint, @sizeOf(u8) *% @bitCast(c_ulonglong, @as(c_longlong, @as(c_int, 4)))));
    config.*.atlas_width_in_pixels = 1024;
    config.*.atlas_height_in_pixels = 1024;
    config.*.atlas_use_border_pixels = 0;
    config.*.ticks_to_decay_texture = @as(c_int, 60) * @as(c_int, 30);
    config.*.lonely_buffer_count_till_flush = 64;
    config.*.ratio_to_decay_atlas = 0.5;
    config.*.ratio_to_merge_atlases = 0.25;
    config.*.batch_callback = null;
    config.*.generate_texture_callback = null;
    config.*.delete_texture_callback = null;
    config.*.sprites_sorter_callback = null;
    config.*.allocator_context = null;
}
pub export fn hashtable_init(arg_table: [*c]hashtable_t, arg_item_size: c_int, arg_initial_capacity: c_int, arg_memctx: ?*c_void) void {
    var table = arg_table;
    var item_size = arg_item_size;
    var initial_capacity = arg_initial_capacity;
    var memctx = arg_memctx;
    initial_capacity = @bitCast(c_int, hashtable_internal_pow2ceil(if (initial_capacity >= @as(c_int, 0)) @bitCast(c_uint, initial_capacity) else @as(c_uint, 32)));
    table.*.memctx = memctx;
    table.*.count = 0;
    table.*.item_size = item_size;
    table.*.slot_capacity = @bitCast(c_int, hashtable_internal_pow2ceil(@bitCast(c_uint, initial_capacity + @divTrunc(initial_capacity, @as(c_int, 2)))));
    var slots_size: c_int = @bitCast(c_int, @truncate(c_uint, @bitCast(c_ulonglong, @as(c_longlong, table.*.slot_capacity)) *% @sizeOf(struct_hashtable_internal_slot_t)));
    table.*.slots = @ptrCast([*c]struct_hashtable_internal_slot_t, @alignCast(@import("std").meta.alignment(struct_hashtable_internal_slot_t), malloc(@bitCast(usize, @as(c_longlong, slots_size)))));
    _ = @as(c_int, 0);
    _ = memset(@ptrCast(?*c_void, table.*.slots), @as(c_int, 0), @bitCast(usize, @as(c_longlong, slots_size)));
    table.*.item_capacity = @bitCast(c_int, hashtable_internal_pow2ceil(@bitCast(c_uint, initial_capacity)));
    table.*.items_key = @ptrCast([*c]c_ulonglong, @alignCast(@import("std").meta.alignment(c_ulonglong), malloc((@bitCast(c_ulonglong, @as(c_longlong, table.*.item_capacity)) *% ((@sizeOf(c_ulonglong) +% @sizeOf(c_int)) +% @bitCast(c_ulonglong, @as(c_longlong, table.*.item_size)))) +% @bitCast(c_ulonglong, @as(c_longlong, table.*.item_size)))));
    _ = @as(c_int, 0);
    table.*.items_slot = @ptrCast([*c]c_int, @alignCast(@import("std").meta.alignment(c_int), table.*.items_key + @bitCast(usize, @intCast(isize, table.*.item_capacity))));
    table.*.items_data = @ptrCast(?*c_void, table.*.items_slot + @bitCast(usize, @intCast(isize, table.*.item_capacity)));
    table.*.swap_temp = @intToPtr(?*c_void, @intCast(usize, @ptrToInt(table.*.items_data)) +% @bitCast(c_ulonglong, @as(c_longlong, table.*.item_size * table.*.item_capacity)));
}
pub export fn hashtable_term(arg_table: [*c]hashtable_t) void {
    var table = arg_table;
    free(@ptrCast(?*c_void, table.*.items_key));
    free(@ptrCast(?*c_void, table.*.slots));
}
pub export fn hashtable_insert(arg_table: [*c]hashtable_t, arg_key: c_ulonglong, arg_item: ?*const c_void) ?*c_void {
    var table = arg_table;
    var key = arg_key;
    var item = arg_item;
    _ = @as(c_int, 0);
    if (table.*.count >= (table.*.slot_capacity - @divTrunc(table.*.slot_capacity, @as(c_int, 3)))) {
        hashtable_internal_expand_slots(table);
    }
    const slot_mask: c_int = table.*.slot_capacity - @as(c_int, 1);
    const hash: c_uint = hashtable_internal_calculate_hash(key);
    const base_slot: c_int = @bitCast(c_int, hash & @bitCast(c_uint, slot_mask));
    var base_count: c_int = (blk: {
        const tmp = base_slot;
        if (tmp >= 0) break :blk table.*.slots + @intCast(usize, tmp) else break :blk table.*.slots - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
    }).*.base_count;
    var slot: c_int = base_slot;
    var first_free: c_int = slot;
    while (base_count != 0) {
        const slot_hash: c_uint = (blk: {
            const tmp = slot;
            if (tmp >= 0) break :blk table.*.slots + @intCast(usize, tmp) else break :blk table.*.slots - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
        }).*.key_hash;
        if ((slot_hash == @bitCast(c_uint, @as(c_int, 0))) and ((blk: {
            const tmp = first_free;
            if (tmp >= 0) break :blk table.*.slots + @intCast(usize, tmp) else break :blk table.*.slots - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
        }).*.key_hash != @bitCast(c_uint, @as(c_int, 0)))) {
            first_free = slot;
        }
        var slot_base: c_int = @bitCast(c_int, slot_hash & @bitCast(c_uint, slot_mask));
        if (slot_base == base_slot) {
            base_count -= 1;
        }
        slot = (slot + @as(c_int, 1)) & slot_mask;
    }
    slot = first_free;
    while ((blk: {
        const tmp = slot;
        if (tmp >= 0) break :blk table.*.slots + @intCast(usize, tmp) else break :blk table.*.slots - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
    }).*.key_hash != 0) {
        slot = (slot + @as(c_int, 1)) & slot_mask;
    }
    if (table.*.count >= table.*.item_capacity) {
        hashtable_internal_expand_items(table);
    }
    _ = @as(c_int, 0);
    _ = @as(c_int, 0);
    (blk: {
        const tmp = slot;
        if (tmp >= 0) break :blk table.*.slots + @intCast(usize, tmp) else break :blk table.*.slots - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
    }).*.key_hash = hash;
    (blk: {
        const tmp = slot;
        if (tmp >= 0) break :blk table.*.slots + @intCast(usize, tmp) else break :blk table.*.slots - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
    }).*.item_index = table.*.count;
    (blk: {
        const tmp = base_slot;
        if (tmp >= 0) break :blk table.*.slots + @intCast(usize, tmp) else break :blk table.*.slots - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
    }).*.base_count += 1;
    var dest_item: ?*c_void = @intToPtr(?*c_void, @intCast(usize, @ptrToInt(table.*.items_data)) +% @bitCast(c_ulonglong, @as(c_longlong, table.*.count * table.*.item_size)));
    _ = memcpy(dest_item, item, @bitCast(usize, @as(c_longlong, table.*.item_size)));
    (blk: {
        const tmp = table.*.count;
        if (tmp >= 0) break :blk table.*.items_key + @intCast(usize, tmp) else break :blk table.*.items_key - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
    }).* = key;
    (blk: {
        const tmp = table.*.count;
        if (tmp >= 0) break :blk table.*.items_slot + @intCast(usize, tmp) else break :blk table.*.items_slot - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
    }).* = slot;
    table.*.count += 1;
    return dest_item;
}
pub export fn hashtable_remove(arg_table: [*c]hashtable_t, arg_key: c_ulonglong) void {
    var table = arg_table;
    var key = arg_key;
    const slot: c_int = hashtable_internal_find_slot(table, key);
    _ = @as(c_int, 0);
    const slot_mask: c_int = table.*.slot_capacity - @as(c_int, 1);
    const hash: c_uint = (blk: {
        const tmp = slot;
        if (tmp >= 0) break :blk table.*.slots + @intCast(usize, tmp) else break :blk table.*.slots - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
    }).*.key_hash;
    const base_slot: c_int = @bitCast(c_int, hash & @bitCast(c_uint, slot_mask));
    _ = @as(c_int, 0);
    (blk: {
        const tmp = base_slot;
        if (tmp >= 0) break :blk table.*.slots + @intCast(usize, tmp) else break :blk table.*.slots - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
    }).*.base_count -= 1;
    (blk: {
        const tmp = slot;
        if (tmp >= 0) break :blk table.*.slots + @intCast(usize, tmp) else break :blk table.*.slots - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
    }).*.key_hash = 0;
    var index: c_int = (blk: {
        const tmp = slot;
        if (tmp >= 0) break :blk table.*.slots + @intCast(usize, tmp) else break :blk table.*.slots - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
    }).*.item_index;
    var last_index: c_int = table.*.count - @as(c_int, 1);
    if (index != last_index) {
        (blk: {
            const tmp = index;
            if (tmp >= 0) break :blk table.*.items_key + @intCast(usize, tmp) else break :blk table.*.items_key - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
        }).* = (blk: {
            const tmp = last_index;
            if (tmp >= 0) break :blk table.*.items_key + @intCast(usize, tmp) else break :blk table.*.items_key - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
        }).*;
        (blk: {
            const tmp = index;
            if (tmp >= 0) break :blk table.*.items_slot + @intCast(usize, tmp) else break :blk table.*.items_slot - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
        }).* = (blk: {
            const tmp = last_index;
            if (tmp >= 0) break :blk table.*.items_slot + @intCast(usize, tmp) else break :blk table.*.items_slot - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
        }).*;
        var dst_item: ?*c_void = @intToPtr(?*c_void, @intCast(usize, @ptrToInt(table.*.items_data)) +% @bitCast(c_ulonglong, @as(c_longlong, index * table.*.item_size)));
        var src_item: ?*c_void = @intToPtr(?*c_void, @intCast(usize, @ptrToInt(table.*.items_data)) +% @bitCast(c_ulonglong, @as(c_longlong, last_index * table.*.item_size)));
        _ = memcpy(dst_item, src_item, @bitCast(usize, @as(c_longlong, table.*.item_size)));
        (blk: {
            const tmp = (blk_1: {
                const tmp_2 = last_index;
                if (tmp_2 >= 0) break :blk_1 table.*.items_slot + @intCast(usize, tmp_2) else break :blk_1 table.*.items_slot - ~@bitCast(usize, @intCast(isize, tmp_2) +% -1);
            }).*;
            if (tmp >= 0) break :blk table.*.slots + @intCast(usize, tmp) else break :blk table.*.slots - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
        }).*.item_index = index;
    }
    table.*.count -= 1;
}
pub export fn hashtable_clear(arg_table: [*c]hashtable_t) void {
    var table = arg_table;
    table.*.count = 0;
    _ = memset(@ptrCast(?*c_void, table.*.slots), @as(c_int, 0), @bitCast(c_ulonglong, @as(c_longlong, table.*.slot_capacity)) *% @sizeOf(struct_hashtable_internal_slot_t));
}
pub export fn hashtable_find(arg_table: [*c]const hashtable_t, arg_key: c_ulonglong) ?*c_void {
    var table = arg_table;
    var key = arg_key;
    const slot: c_int = hashtable_internal_find_slot(table, key);
    if (slot < @as(c_int, 0)) return null;
    const index: c_int = (blk: {
        const tmp = slot;
        if (tmp >= 0) break :blk table.*.slots + @intCast(usize, tmp) else break :blk table.*.slots - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
    }).*.item_index;
    const item: ?*c_void = @intToPtr(?*c_void, @intCast(usize, @ptrToInt(table.*.items_data)) +% @bitCast(c_ulonglong, @as(c_longlong, index * table.*.item_size)));
    return item;
}
pub export fn hashtable_count(arg_table: [*c]const hashtable_t) c_int {
    var table = arg_table;
    return table.*.count;
}
pub export fn hashtable_items(arg_table: [*c]const hashtable_t) ?*c_void {
    var table = arg_table;
    return table.*.items_data;
}
pub export fn hashtable_keys(arg_table: [*c]const hashtable_t) [*c]const c_ulonglong {
    var table = arg_table;
    return table.*.items_key;
}
pub export fn hashtable_swap(arg_table: [*c]hashtable_t, arg_index_a: c_int, arg_index_b: c_int) void {
    var table = arg_table;
    var index_a = arg_index_a;
    var index_b = arg_index_b;
    if ((((index_a < @as(c_int, 0)) or (index_a >= table.*.count)) or (index_b < @as(c_int, 0))) or (index_b >= table.*.count)) return;
    var slot_a: c_int = (blk: {
        const tmp = index_a;
        if (tmp >= 0) break :blk table.*.items_slot + @intCast(usize, tmp) else break :blk table.*.items_slot - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
    }).*;
    var slot_b: c_int = (blk: {
        const tmp = index_b;
        if (tmp >= 0) break :blk table.*.items_slot + @intCast(usize, tmp) else break :blk table.*.items_slot - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
    }).*;
    (blk: {
        const tmp = index_a;
        if (tmp >= 0) break :blk table.*.items_slot + @intCast(usize, tmp) else break :blk table.*.items_slot - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
    }).* = slot_b;
    (blk: {
        const tmp = index_b;
        if (tmp >= 0) break :blk table.*.items_slot + @intCast(usize, tmp) else break :blk table.*.items_slot - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
    }).* = slot_a;
    var temp_key: c_ulonglong = (blk: {
        const tmp = index_a;
        if (tmp >= 0) break :blk table.*.items_key + @intCast(usize, tmp) else break :blk table.*.items_key - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
    }).*;
    (blk: {
        const tmp = index_a;
        if (tmp >= 0) break :blk table.*.items_key + @intCast(usize, tmp) else break :blk table.*.items_key - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
    }).* = (blk: {
        const tmp = index_b;
        if (tmp >= 0) break :blk table.*.items_key + @intCast(usize, tmp) else break :blk table.*.items_key - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
    }).*;
    (blk: {
        const tmp = index_b;
        if (tmp >= 0) break :blk table.*.items_key + @intCast(usize, tmp) else break :blk table.*.items_key - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
    }).* = temp_key;
    var item_a: ?*c_void = @intToPtr(?*c_void, @intCast(usize, @ptrToInt(table.*.items_data)) +% @bitCast(c_ulonglong, @as(c_longlong, index_a * table.*.item_size)));
    var item_b: ?*c_void = @intToPtr(?*c_void, @intCast(usize, @ptrToInt(table.*.items_data)) +% @bitCast(c_ulonglong, @as(c_longlong, index_b * table.*.item_size)));
    _ = memcpy(table.*.swap_temp, item_a, @bitCast(c_ulonglong, @as(c_longlong, table.*.item_size)));
    _ = memcpy(item_a, item_b, @bitCast(c_ulonglong, @as(c_longlong, table.*.item_size)));
    _ = memcpy(item_b, table.*.swap_temp, @bitCast(c_ulonglong, @as(c_longlong, table.*.item_size)));
    (blk: {
        const tmp = slot_a;
        if (tmp >= 0) break :blk table.*.slots + @intCast(usize, tmp) else break :blk table.*.slots - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
    }).*.item_index = index_b;
    (blk: {
        const tmp = slot_b;
        if (tmp >= 0) break :blk table.*.slots + @intCast(usize, tmp) else break :blk table.*.slots - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
    }).*.item_index = index_a;
}
pub const spritebatch_internal_sprite_t = extern struct {
    image_id: c_ulonglong,
    sort_bits: c_int,
    w: c_int,
    h: c_int,
    x: f32,
    y: f32,
    sx: f32,
    sy: f32,
    c: f32,
    s: f32,
};
pub const spritebatch_internal_texture_t = extern struct {
    timestamp: c_int,
    w: c_int,
    h: c_int,
    minx: f32,
    miny: f32,
    maxx: f32,
    maxy: f32,
    image_id: c_ulonglong,
};
pub const spritebatch_internal_lonely_texture_t = extern struct {
    timestamp: c_int,
    w: c_int,
    h: c_int,
    image_id: c_ulonglong,
    texture_id: c_ulonglong,
};
pub const __builtin_va_list = [*c]u8;
pub const __gnuc_va_list = __builtin_va_list;
pub const va_list = __gnuc_va_list; // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\_mingw.h:584:3: warning: TODO implement translation of stmt class GCCAsmStmtClass
// C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\_mingw.h:581:36: warning: unable to translate function, demoted to extern
pub extern fn __debugbreak() callconv(.C) void;
pub extern fn __mingw_get_crt_info() [*c]const u8;
pub const rsize_t = usize;
pub const ptrdiff_t = c_longlong;
pub const wchar_t = c_ushort;
pub const wint_t = c_ushort;
pub const wctype_t = c_ushort;
pub const errno_t = c_int;
pub const __time32_t = c_long;
pub const __time64_t = c_longlong;
pub const time_t = __time64_t;
pub const struct_tagLC_ID = extern struct {
    wLanguage: c_ushort,
    wCountry: c_ushort,
    wCodePage: c_ushort,
};
pub const LC_ID = struct_tagLC_ID;
const struct_unnamed_1 = extern struct {
    locale: [*c]u8,
    wlocale: [*c]wchar_t,
    refcount: [*c]c_int,
    wrefcount: [*c]c_int,
};
pub const struct_lconv = opaque {};
pub const struct___lc_time_data = opaque {};
pub const struct_threadlocaleinfostruct = extern struct {
    refcount: c_int,
    lc_codepage: c_uint,
    lc_collate_cp: c_uint,
    lc_handle: [6]c_ulong,
    lc_id: [6]LC_ID,
    lc_category: [6]struct_unnamed_1,
    lc_clike: c_int,
    mb_cur_max: c_int,
    lconv_intl_refcount: [*c]c_int,
    lconv_num_refcount: [*c]c_int,
    lconv_mon_refcount: [*c]c_int,
    lconv: ?*struct_lconv,
    ctype1_refcount: [*c]c_int,
    ctype1: [*c]c_ushort,
    pctype: [*c]const c_ushort,
    pclmap: [*c]const u8,
    pcumap: [*c]const u8,
    lc_time_curr: ?*struct___lc_time_data,
};
pub const struct_threadmbcinfostruct = opaque {};
pub const pthreadlocinfo = [*c]struct_threadlocaleinfostruct;
pub const pthreadmbcinfo = ?*struct_threadmbcinfostruct;
pub const struct_localeinfo_struct = extern struct {
    locinfo: pthreadlocinfo,
    mbcinfo: pthreadmbcinfo,
};
pub const _locale_tstruct = struct_localeinfo_struct;
pub const _locale_t = [*c]struct_localeinfo_struct;
pub const LPLC_ID = [*c]struct_tagLC_ID;
pub const threadlocinfo = struct_threadlocaleinfostruct;
pub extern fn _itow_s(_Val: c_int, _DstBuf: [*c]wchar_t, _SizeInWords: usize, _Radix: c_int) errno_t;
pub extern fn _ltow_s(_Val: c_long, _DstBuf: [*c]wchar_t, _SizeInWords: usize, _Radix: c_int) errno_t;
pub extern fn _ultow_s(_Val: c_ulong, _DstBuf: [*c]wchar_t, _SizeInWords: usize, _Radix: c_int) errno_t;
pub extern fn _wgetenv_s(_ReturnSize: [*c]usize, _DstBuf: [*c]wchar_t, _DstSizeInWords: usize, _VarName: [*c]const wchar_t) errno_t;
pub extern fn _wdupenv_s(_Buffer: [*c][*c]wchar_t, _BufferSizeInWords: [*c]usize, _VarName: [*c]const wchar_t) errno_t;
pub extern fn _i64tow_s(_Val: c_longlong, _DstBuf: [*c]wchar_t, _SizeInWords: usize, _Radix: c_int) errno_t;
pub extern fn _ui64tow_s(_Val: c_ulonglong, _DstBuf: [*c]wchar_t, _SizeInWords: usize, _Radix: c_int) errno_t;
pub extern fn _wmakepath_s(_PathResult: [*c]wchar_t, _SizeInWords: usize, _Drive: [*c]const wchar_t, _Dir: [*c]const wchar_t, _Filename: [*c]const wchar_t, _Ext: [*c]const wchar_t) errno_t;
pub extern fn _wputenv_s(_Name: [*c]const wchar_t, _Value: [*c]const wchar_t) errno_t;
pub extern fn _wsearchenv_s(_Filename: [*c]const wchar_t, _EnvVar: [*c]const wchar_t, _ResultPath: [*c]wchar_t, _SizeInWords: usize) errno_t;
pub extern fn _wsplitpath_s(_FullPath: [*c]const wchar_t, _Drive: [*c]wchar_t, _DriveSizeInWords: usize, _Dir: [*c]wchar_t, _DirSizeInWords: usize, _Filename: [*c]wchar_t, _FilenameSizeInWords: usize, _Ext: [*c]wchar_t, _ExtSizeInWords: usize) errno_t;
pub const _onexit_t = ?fn () callconv(.C) c_int;
pub const struct__div_t = extern struct {
    quot: c_int,
    rem: c_int,
};
pub const div_t = struct__div_t;
pub const struct__ldiv_t = extern struct {
    quot: c_long,
    rem: c_long,
};
pub const ldiv_t = struct__ldiv_t;
pub const _LDOUBLE = extern struct {
    ld: [10]u8,
};
pub const _CRT_DOUBLE = extern struct {
    x: f64,
};
pub const _CRT_FLOAT = extern struct {
    f: f32,
};
pub const _LONGDOUBLE = extern struct {
    x: c_longdouble,
};
pub const _LDBL12 = extern struct {
    ld12: [12]u8,
};
pub extern var __imp___mb_cur_max: [*c]c_int;
pub extern fn ___mb_cur_max_func() c_int;
pub const _purecall_handler = ?fn () callconv(.C) void;
pub extern fn _set_purecall_handler(_Handler: _purecall_handler) _purecall_handler;
pub extern fn _get_purecall_handler() _purecall_handler;
pub const _invalid_parameter_handler = ?fn ([*c]const wchar_t, [*c]const wchar_t, [*c]const wchar_t, c_uint, usize) callconv(.C) void;
pub extern fn _set_invalid_parameter_handler(_Handler: _invalid_parameter_handler) _invalid_parameter_handler;
pub extern fn _get_invalid_parameter_handler() _invalid_parameter_handler;
pub extern fn _errno() [*c]c_int;
pub extern fn _set_errno(_Value: c_int) errno_t;
pub extern fn _get_errno(_Value: [*c]c_int) errno_t;
pub extern fn __doserrno() [*c]c_ulong;
pub extern fn _set_doserrno(_Value: c_ulong) errno_t;
pub extern fn _get_doserrno(_Value: [*c]c_ulong) errno_t;
pub extern var _sys_errlist: [1][*c]u8;
pub extern var _sys_nerr: c_int;
pub extern fn __p___argv() [*c][*c][*c]u8;
pub extern fn __p__fmode() [*c]c_int;
pub extern fn _get_pgmptr(_Value: [*c][*c]u8) errno_t;
pub extern fn _get_wpgmptr(_Value: [*c][*c]wchar_t) errno_t;
pub extern fn _set_fmode(_Mode: c_int) errno_t;
pub extern fn _get_fmode(_PMode: [*c]c_int) errno_t;
pub extern var __imp___argc: [*c]c_int;
pub extern var __imp___argv: [*c][*c][*c]u8;
pub extern var __imp___wargv: [*c][*c][*c]wchar_t;
pub extern var __imp__environ: [*c][*c][*c]u8;
pub extern var __imp__wenviron: [*c][*c][*c]wchar_t;
pub extern var __imp__pgmptr: [*c][*c]u8;
pub extern var __imp__wpgmptr: [*c][*c]wchar_t;
pub extern var __imp__osplatform: [*c]c_uint;
pub extern var __imp__osver: [*c]c_uint;
pub extern var __imp__winver: [*c]c_uint;
pub extern var __imp__winmajor: [*c]c_uint;
pub extern var __imp__winminor: [*c]c_uint;
pub extern fn _get_osplatform(_Value: [*c]c_uint) errno_t;
pub extern fn _get_osver(_Value: [*c]c_uint) errno_t;
pub extern fn _get_winver(_Value: [*c]c_uint) errno_t;
pub extern fn _get_winmajor(_Value: [*c]c_uint) errno_t;
pub extern fn _get_winminor(_Value: [*c]c_uint) errno_t;
pub extern fn exit(_Code: c_int) noreturn;
pub extern fn _exit(_Code: c_int) noreturn;
pub fn _Exit(arg_status: c_int) callconv(.C) noreturn {
    var status = arg_status;
    _exit(status);
}
pub extern fn abort() noreturn;
pub extern fn _set_abort_behavior(_Flags: c_uint, _Mask: c_uint) c_uint;
pub extern fn abs(_X: c_int) c_int;
pub extern fn labs(_X: c_long) c_long; // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\stdlib.h:421:12: warning: TODO implement function '__builtin_llabs' in std.zig.c_builtins
// C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\stdlib.h:420:41: warning: unable to translate function, demoted to extern
pub extern fn _abs64(arg_x: c_longlong) callconv(.C) c_longlong;
pub extern fn atexit(?fn () callconv(.C) void) c_int;
pub extern fn atof(_String: [*c]const u8) f64;
pub extern fn _atof_l(_String: [*c]const u8, _Locale: _locale_t) f64;
pub extern fn atoi(_Str: [*c]const u8) c_int;
pub extern fn _atoi_l(_Str: [*c]const u8, _Locale: _locale_t) c_int;
pub extern fn atol(_Str: [*c]const u8) c_long;
pub extern fn _atol_l(_Str: [*c]const u8, _Locale: _locale_t) c_long;
pub extern fn bsearch(_Key: ?*const c_void, _Base: ?*const c_void, _NumOfElements: usize, _SizeOfElements: usize, _PtFuncCompare: ?fn (?*const c_void, ?*const c_void) callconv(.C) c_int) ?*c_void;
pub extern fn qsort(_Base: ?*c_void, _NumOfElements: usize, _SizeOfElements: usize, _PtFuncCompare: ?fn (?*const c_void, ?*const c_void) callconv(.C) c_int) void;
pub extern fn _byteswap_ushort(_Short: c_ushort) c_ushort;
pub extern fn _byteswap_ulong(_Long: c_ulong) c_ulong;
pub extern fn _byteswap_uint64(_Int64: c_ulonglong) c_ulonglong;
pub extern fn div(_Numerator: c_int, _Denominator: c_int) div_t;
pub extern fn getenv(_VarName: [*c]const u8) [*c]u8;
pub extern fn _itoa(_Value: c_int, _Dest: [*c]u8, _Radix: c_int) [*c]u8;
pub extern fn _i64toa(_Val: c_longlong, _DstBuf: [*c]u8, _Radix: c_int) [*c]u8;
pub extern fn _ui64toa(_Val: c_ulonglong, _DstBuf: [*c]u8, _Radix: c_int) [*c]u8;
pub extern fn _atoi64(_String: [*c]const u8) c_longlong;
pub extern fn _atoi64_l(_String: [*c]const u8, _Locale: _locale_t) c_longlong;
pub extern fn _strtoi64(_String: [*c]const u8, _EndPtr: [*c][*c]u8, _Radix: c_int) c_longlong;
pub extern fn _strtoi64_l(_String: [*c]const u8, _EndPtr: [*c][*c]u8, _Radix: c_int, _Locale: _locale_t) c_longlong;
pub extern fn _strtoui64(_String: [*c]const u8, _EndPtr: [*c][*c]u8, _Radix: c_int) c_ulonglong;
pub extern fn _strtoui64_l(_String: [*c]const u8, _EndPtr: [*c][*c]u8, _Radix: c_int, _Locale: _locale_t) c_ulonglong;
pub extern fn ldiv(_Numerator: c_long, _Denominator: c_long) ldiv_t;
pub extern fn _ltoa(_Value: c_long, _Dest: [*c]u8, _Radix: c_int) [*c]u8;
pub extern fn mblen(_Ch: [*c]const u8, _MaxCount: usize) c_int;
pub extern fn _mblen_l(_Ch: [*c]const u8, _MaxCount: usize, _Locale: _locale_t) c_int;
pub extern fn _mbstrlen(_Str: [*c]const u8) usize;
pub extern fn _mbstrlen_l(_Str: [*c]const u8, _Locale: _locale_t) usize;
pub extern fn _mbstrnlen(_Str: [*c]const u8, _MaxCount: usize) usize;
pub extern fn _mbstrnlen_l(_Str: [*c]const u8, _MaxCount: usize, _Locale: _locale_t) usize;
pub extern fn mbtowc(noalias _DstCh: [*c]wchar_t, noalias _SrcCh: [*c]const u8, _SrcSizeInBytes: usize) c_int;
pub extern fn _mbtowc_l(noalias _DstCh: [*c]wchar_t, noalias _SrcCh: [*c]const u8, _SrcSizeInBytes: usize, _Locale: _locale_t) c_int;
pub extern fn mbstowcs(noalias _Dest: [*c]wchar_t, noalias _Source: [*c]const u8, _MaxCount: usize) usize;
pub extern fn _mbstowcs_l(noalias _Dest: [*c]wchar_t, noalias _Source: [*c]const u8, _MaxCount: usize, _Locale: _locale_t) usize;
pub extern fn mkstemp(template_name: [*c]u8) c_int;
pub extern fn rand() c_int;
pub extern fn _set_error_mode(_Mode: c_int) c_int;
pub extern fn srand(_Seed: c_uint) void;
pub extern fn __mingw_strtod(noalias [*c]const u8, noalias [*c][*c]u8) f64;
pub fn strtod(noalias arg__Str: [*c]const u8, noalias arg__EndPtr: [*c][*c]u8) callconv(.C) f64 {
    var _Str = arg__Str;
    var _EndPtr = arg__EndPtr;
    return __mingw_strtod(_Str, _EndPtr);
}
pub extern fn __mingw_strtof(noalias [*c]const u8, noalias [*c][*c]u8) f32;
pub fn strtof(noalias arg__Str: [*c]const u8, noalias arg__EndPtr: [*c][*c]u8) callconv(.C) f32 {
    var _Str = arg__Str;
    var _EndPtr = arg__EndPtr;
    return __mingw_strtof(_Str, _EndPtr);
}
pub extern fn strtold([*c]const u8, [*c][*c]u8) c_longdouble;
pub extern fn __strtod(noalias [*c]const u8, noalias [*c][*c]u8) f64;
pub extern fn __mingw_strtold(noalias [*c]const u8, noalias [*c][*c]u8) c_longdouble;
pub extern fn _strtod_l(noalias _Str: [*c]const u8, noalias _EndPtr: [*c][*c]u8, _Locale: _locale_t) f64;
pub extern fn strtol(_Str: [*c]const u8, _EndPtr: [*c][*c]u8, _Radix: c_int) c_long;
pub extern fn _strtol_l(noalias _Str: [*c]const u8, noalias _EndPtr: [*c][*c]u8, _Radix: c_int, _Locale: _locale_t) c_long;
pub extern fn strtoul(_Str: [*c]const u8, _EndPtr: [*c][*c]u8, _Radix: c_int) c_ulong;
pub extern fn _strtoul_l(noalias _Str: [*c]const u8, noalias _EndPtr: [*c][*c]u8, _Radix: c_int, _Locale: _locale_t) c_ulong;
pub extern fn system(_Command: [*c]const u8) c_int;
pub extern fn _ultoa(_Value: c_ulong, _Dest: [*c]u8, _Radix: c_int) [*c]u8;
pub extern fn wctomb(_MbCh: [*c]u8, _WCh: wchar_t) c_int;
pub extern fn _wctomb_l(_MbCh: [*c]u8, _WCh: wchar_t, _Locale: _locale_t) c_int;
pub extern fn wcstombs(noalias _Dest: [*c]u8, noalias _Source: [*c]const wchar_t, _MaxCount: usize) usize;
pub extern fn _wcstombs_l(noalias _Dest: [*c]u8, noalias _Source: [*c]const wchar_t, _MaxCount: usize, _Locale: _locale_t) usize;
pub extern fn calloc(_NumOfElements: c_ulonglong, _SizeOfElements: c_ulonglong) ?*c_void;
pub extern fn free(_Memory: ?*c_void) void;
pub extern fn malloc(_Size: c_ulonglong) ?*c_void;
pub extern fn realloc(_Memory: ?*c_void, _NewSize: c_ulonglong) ?*c_void;
pub extern fn _recalloc(_Memory: ?*c_void, _Count: usize, _Size: usize) ?*c_void;
pub extern fn _aligned_free(_Memory: ?*c_void) void;
pub extern fn _aligned_malloc(_Size: usize, _Alignment: usize) ?*c_void;
pub extern fn _aligned_offset_malloc(_Size: usize, _Alignment: usize, _Offset: usize) ?*c_void;
pub extern fn _aligned_realloc(_Memory: ?*c_void, _Size: usize, _Alignment: usize) ?*c_void;
pub extern fn _aligned_recalloc(_Memory: ?*c_void, _Count: usize, _Size: usize, _Alignment: usize) ?*c_void;
pub extern fn _aligned_offset_realloc(_Memory: ?*c_void, _Size: usize, _Alignment: usize, _Offset: usize) ?*c_void;
pub extern fn _aligned_offset_recalloc(_Memory: ?*c_void, _Count: usize, _Size: usize, _Alignment: usize, _Offset: usize) ?*c_void;
pub extern fn _itow(_Value: c_int, _Dest: [*c]wchar_t, _Radix: c_int) [*c]wchar_t;
pub extern fn _ltow(_Value: c_long, _Dest: [*c]wchar_t, _Radix: c_int) [*c]wchar_t;
pub extern fn _ultow(_Value: c_ulong, _Dest: [*c]wchar_t, _Radix: c_int) [*c]wchar_t;
pub extern fn __mingw_wcstod(noalias _Str: [*c]const wchar_t, noalias _EndPtr: [*c][*c]wchar_t) f64;
pub extern fn __mingw_wcstof(noalias nptr: [*c]const wchar_t, noalias endptr: [*c][*c]wchar_t) f32;
pub extern fn __mingw_wcstold(noalias [*c]const wchar_t, noalias [*c][*c]wchar_t) c_longdouble;
pub fn wcstod(noalias arg__Str: [*c]const wchar_t, noalias arg__EndPtr: [*c][*c]wchar_t) callconv(.C) f64 {
    var _Str = arg__Str;
    var _EndPtr = arg__EndPtr;
    return __mingw_wcstod(_Str, _EndPtr);
}
pub fn wcstof(noalias arg__Str: [*c]const wchar_t, noalias arg__EndPtr: [*c][*c]wchar_t) callconv(.C) f32 {
    var _Str = arg__Str;
    var _EndPtr = arg__EndPtr;
    return __mingw_wcstof(_Str, _EndPtr);
}
pub extern fn wcstold(noalias [*c]const wchar_t, noalias [*c][*c]wchar_t) c_longdouble;
pub extern fn _wcstod_l(noalias _Str: [*c]const wchar_t, noalias _EndPtr: [*c][*c]wchar_t, _Locale: _locale_t) f64;
pub extern fn wcstol(noalias _Str: [*c]const wchar_t, noalias _EndPtr: [*c][*c]wchar_t, _Radix: c_int) c_long;
pub extern fn _wcstol_l(noalias _Str: [*c]const wchar_t, noalias _EndPtr: [*c][*c]wchar_t, _Radix: c_int, _Locale: _locale_t) c_long;
pub extern fn wcstoul(noalias _Str: [*c]const wchar_t, noalias _EndPtr: [*c][*c]wchar_t, _Radix: c_int) c_ulong;
pub extern fn _wcstoul_l(noalias _Str: [*c]const wchar_t, noalias _EndPtr: [*c][*c]wchar_t, _Radix: c_int, _Locale: _locale_t) c_ulong;
pub extern fn _wgetenv(_VarName: [*c]const wchar_t) [*c]wchar_t;
pub extern fn _wsystem(_Command: [*c]const wchar_t) c_int;
pub extern fn _wtof(_Str: [*c]const wchar_t) f64;
pub extern fn _wtof_l(_Str: [*c]const wchar_t, _Locale: _locale_t) f64;
pub extern fn _wtoi(_Str: [*c]const wchar_t) c_int;
pub extern fn _wtoi_l(_Str: [*c]const wchar_t, _Locale: _locale_t) c_int;
pub extern fn _wtol(_Str: [*c]const wchar_t) c_long;
pub extern fn _wtol_l(_Str: [*c]const wchar_t, _Locale: _locale_t) c_long;
pub extern fn _i64tow(_Val: c_longlong, _DstBuf: [*c]wchar_t, _Radix: c_int) [*c]wchar_t;
pub extern fn _ui64tow(_Val: c_ulonglong, _DstBuf: [*c]wchar_t, _Radix: c_int) [*c]wchar_t;
pub extern fn _wtoi64(_Str: [*c]const wchar_t) c_longlong;
pub extern fn _wtoi64_l(_Str: [*c]const wchar_t, _Locale: _locale_t) c_longlong;
pub extern fn _wcstoi64(_Str: [*c]const wchar_t, _EndPtr: [*c][*c]wchar_t, _Radix: c_int) c_longlong;
pub extern fn _wcstoi64_l(_Str: [*c]const wchar_t, _EndPtr: [*c][*c]wchar_t, _Radix: c_int, _Locale: _locale_t) c_longlong;
pub extern fn _wcstoui64(_Str: [*c]const wchar_t, _EndPtr: [*c][*c]wchar_t, _Radix: c_int) c_ulonglong;
pub extern fn _wcstoui64_l(_Str: [*c]const wchar_t, _EndPtr: [*c][*c]wchar_t, _Radix: c_int, _Locale: _locale_t) c_ulonglong;
pub extern fn _putenv(_EnvString: [*c]const u8) c_int;
pub extern fn _wputenv(_EnvString: [*c]const wchar_t) c_int;
pub extern fn _fullpath(_FullPath: [*c]u8, _Path: [*c]const u8, _SizeInBytes: usize) [*c]u8;
pub extern fn _ecvt(_Val: f64, _NumOfDigits: c_int, _PtDec: [*c]c_int, _PtSign: [*c]c_int) [*c]u8;
pub extern fn _fcvt(_Val: f64, _NumOfDec: c_int, _PtDec: [*c]c_int, _PtSign: [*c]c_int) [*c]u8;
pub extern fn _gcvt(_Val: f64, _NumOfDigits: c_int, _DstBuf: [*c]u8) [*c]u8;
pub extern fn _atodbl(_Result: [*c]_CRT_DOUBLE, _Str: [*c]u8) c_int;
pub extern fn _atoldbl(_Result: [*c]_LDOUBLE, _Str: [*c]u8) c_int;
pub extern fn _atoflt(_Result: [*c]_CRT_FLOAT, _Str: [*c]u8) c_int;
pub extern fn _atodbl_l(_Result: [*c]_CRT_DOUBLE, _Str: [*c]u8, _Locale: _locale_t) c_int;
pub extern fn _atoldbl_l(_Result: [*c]_LDOUBLE, _Str: [*c]u8, _Locale: _locale_t) c_int;
pub extern fn _atoflt_l(_Result: [*c]_CRT_FLOAT, _Str: [*c]u8, _Locale: _locale_t) c_int;
pub extern fn _lrotl(c_ulong, c_int) c_ulong;
pub extern fn _lrotr(c_ulong, c_int) c_ulong;
pub extern fn _makepath(_Path: [*c]u8, _Drive: [*c]const u8, _Dir: [*c]const u8, _Filename: [*c]const u8, _Ext: [*c]const u8) void;
pub extern fn _onexit(_Func: _onexit_t) _onexit_t;
pub extern fn perror(_ErrMsg: [*c]const u8) void;
pub extern fn _rotl64(_Val: c_ulonglong, _Shift: c_int) c_ulonglong;
pub extern fn _rotr64(Value: c_ulonglong, Shift: c_int) c_ulonglong;
pub extern fn _rotr(_Val: c_uint, _Shift: c_int) c_uint;
pub extern fn _rotl(_Val: c_uint, _Shift: c_int) c_uint;
pub extern fn _searchenv(_Filename: [*c]const u8, _EnvVar: [*c]const u8, _ResultPath: [*c]u8) void;
pub extern fn _splitpath(_FullPath: [*c]const u8, _Drive: [*c]u8, _Dir: [*c]u8, _Filename: [*c]u8, _Ext: [*c]u8) void;
pub extern fn _swab(_Buf1: [*c]u8, _Buf2: [*c]u8, _SizeInBytes: c_int) void;
pub extern fn _wfullpath(_FullPath: [*c]wchar_t, _Path: [*c]const wchar_t, _SizeInWords: usize) [*c]wchar_t;
pub extern fn _wmakepath(_ResultPath: [*c]wchar_t, _Drive: [*c]const wchar_t, _Dir: [*c]const wchar_t, _Filename: [*c]const wchar_t, _Ext: [*c]const wchar_t) void;
pub extern fn _wperror(_ErrMsg: [*c]const wchar_t) void;
pub extern fn _wsearchenv(_Filename: [*c]const wchar_t, _EnvVar: [*c]const wchar_t, _ResultPath: [*c]wchar_t) void;
pub extern fn _wsplitpath(_FullPath: [*c]const wchar_t, _Drive: [*c]wchar_t, _Dir: [*c]wchar_t, _Filename: [*c]wchar_t, _Ext: [*c]wchar_t) void;
pub const _beep = @compileError("unable to resolve function type TypeClass.MacroQualified"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\stdlib.h:681:24
pub const _seterrormode = @compileError("unable to resolve function type TypeClass.MacroQualified"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\stdlib.h:683:24
pub const _sleep = @compileError("unable to resolve function type TypeClass.MacroQualified"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\stdlib.h:684:24
pub extern fn ecvt(_Val: f64, _NumOfDigits: c_int, _PtDec: [*c]c_int, _PtSign: [*c]c_int) [*c]u8;
pub extern fn fcvt(_Val: f64, _NumOfDec: c_int, _PtDec: [*c]c_int, _PtSign: [*c]c_int) [*c]u8;
pub extern fn gcvt(_Val: f64, _NumOfDigits: c_int, _DstBuf: [*c]u8) [*c]u8;
pub extern fn itoa(_Val: c_int, _DstBuf: [*c]u8, _Radix: c_int) [*c]u8;
pub extern fn ltoa(_Val: c_long, _DstBuf: [*c]u8, _Radix: c_int) [*c]u8;
pub extern fn putenv(_EnvString: [*c]const u8) c_int;
pub extern fn swab(_Buf1: [*c]u8, _Buf2: [*c]u8, _SizeInBytes: c_int) void;
pub extern fn ultoa(_Val: c_ulong, _Dstbuf: [*c]u8, _Radix: c_int) [*c]u8;
pub extern fn onexit(_Func: _onexit_t) _onexit_t;
pub const lldiv_t = extern struct {
    quot: c_longlong,
    rem: c_longlong,
};
pub extern fn lldiv(c_longlong, c_longlong) lldiv_t;
pub fn llabs(arg__j: c_longlong) callconv(.C) c_longlong {
    var _j = arg__j;
    return if (_j >= @bitCast(c_longlong, @as(c_longlong, @as(c_int, 0)))) _j else -_j;
}
pub extern fn strtoll([*c]const u8, [*c][*c]u8, c_int) c_longlong;
pub extern fn strtoull([*c]const u8, [*c][*c]u8, c_int) c_ulonglong;
pub fn atoll(arg__c: [*c]const u8) callconv(.C) c_longlong {
    var _c = arg__c;
    return _atoi64(_c);
}
pub fn wtoll(arg__w: [*c]const wchar_t) callconv(.C) c_longlong {
    var _w = arg__w;
    return _wtoi64(_w);
}
pub fn lltoa(arg__n: c_longlong, arg__c: [*c]u8, arg__i: c_int) callconv(.C) [*c]u8 {
    var _n = arg__n;
    var _c = arg__c;
    var _i = arg__i;
    return _i64toa(_n, _c, _i);
}
pub fn ulltoa(arg__n: c_ulonglong, arg__c: [*c]u8, arg__i: c_int) callconv(.C) [*c]u8 {
    var _n = arg__n;
    var _c = arg__c;
    var _i = arg__i;
    return _ui64toa(_n, _c, _i);
}
pub fn lltow(arg__n: c_longlong, arg__w: [*c]wchar_t, arg__i: c_int) callconv(.C) [*c]wchar_t {
    var _n = arg__n;
    var _w = arg__w;
    var _i = arg__i;
    return _i64tow(_n, _w, _i);
}
pub fn ulltow(arg__n: c_ulonglong, arg__w: [*c]wchar_t, arg__i: c_int) callconv(.C) [*c]wchar_t {
    var _n = arg__n;
    var _w = arg__w;
    var _i = arg__i;
    return _ui64tow(_n, _w, _i);
}
pub extern fn bsearch_s(_Key: ?*const c_void, _Base: ?*const c_void, _NumOfElements: rsize_t, _SizeOfElements: rsize_t, _PtFuncCompare: ?fn (?*c_void, ?*const c_void, ?*const c_void) callconv(.C) c_int, _Context: ?*c_void) ?*c_void;
pub extern fn _dupenv_s(_PBuffer: [*c][*c]u8, _PBufferSizeInBytes: [*c]usize, _VarName: [*c]const u8) errno_t;
pub extern fn getenv_s(_ReturnSize: [*c]usize, _DstBuf: [*c]u8, _DstSize: rsize_t, _VarName: [*c]const u8) errno_t;
pub extern fn _itoa_s(_Value: c_int, _DstBuf: [*c]u8, _Size: usize, _Radix: c_int) errno_t;
pub extern fn _i64toa_s(_Val: c_longlong, _DstBuf: [*c]u8, _Size: usize, _Radix: c_int) errno_t;
pub extern fn _ui64toa_s(_Val: c_ulonglong, _DstBuf: [*c]u8, _Size: usize, _Radix: c_int) errno_t;
pub extern fn _ltoa_s(_Val: c_long, _DstBuf: [*c]u8, _Size: usize, _Radix: c_int) errno_t;
pub extern fn mbstowcs_s(_PtNumOfCharConverted: [*c]usize, _DstBuf: [*c]wchar_t, _SizeInWords: usize, _SrcBuf: [*c]const u8, _MaxCount: usize) errno_t;
pub extern fn _mbstowcs_s_l(_PtNumOfCharConverted: [*c]usize, _DstBuf: [*c]wchar_t, _SizeInWords: usize, _SrcBuf: [*c]const u8, _MaxCount: usize, _Locale: _locale_t) errno_t;
pub extern fn _ultoa_s(_Val: c_ulong, _DstBuf: [*c]u8, _Size: usize, _Radix: c_int) errno_t;
pub extern fn wctomb_s(_SizeConverted: [*c]c_int, _MbCh: [*c]u8, _SizeInBytes: rsize_t, _WCh: wchar_t) errno_t;
pub extern fn _wctomb_s_l(_SizeConverted: [*c]c_int, _MbCh: [*c]u8, _SizeInBytes: usize, _WCh: wchar_t, _Locale: _locale_t) errno_t;
pub extern fn wcstombs_s(_PtNumOfCharConverted: [*c]usize, _Dst: [*c]u8, _DstSizeInBytes: usize, _Src: [*c]const wchar_t, _MaxCountInBytes: usize) errno_t;
pub extern fn _wcstombs_s_l(_PtNumOfCharConverted: [*c]usize, _Dst: [*c]u8, _DstSizeInBytes: usize, _Src: [*c]const wchar_t, _MaxCountInBytes: usize, _Locale: _locale_t) errno_t;
pub extern fn _ecvt_s(_DstBuf: [*c]u8, _Size: usize, _Val: f64, _NumOfDights: c_int, _PtDec: [*c]c_int, _PtSign: [*c]c_int) errno_t;
pub extern fn _fcvt_s(_DstBuf: [*c]u8, _Size: usize, _Val: f64, _NumOfDec: c_int, _PtDec: [*c]c_int, _PtSign: [*c]c_int) errno_t;
pub extern fn _gcvt_s(_DstBuf: [*c]u8, _Size: usize, _Val: f64, _NumOfDigits: c_int) errno_t;
pub extern fn _makepath_s(_PathResult: [*c]u8, _Size: usize, _Drive: [*c]const u8, _Dir: [*c]const u8, _Filename: [*c]const u8, _Ext: [*c]const u8) errno_t;
pub extern fn _putenv_s(_Name: [*c]const u8, _Value: [*c]const u8) errno_t;
pub extern fn _searchenv_s(_Filename: [*c]const u8, _EnvVar: [*c]const u8, _ResultPath: [*c]u8, _SizeInBytes: usize) errno_t;
pub extern fn _splitpath_s(_FullPath: [*c]const u8, _Drive: [*c]u8, _DriveSize: usize, _Dir: [*c]u8, _DirSize: usize, _Filename: [*c]u8, _FilenameSize: usize, _Ext: [*c]u8, _ExtSize: usize) errno_t;
pub extern fn qsort_s(_Base: ?*c_void, _NumOfElements: usize, _SizeOfElements: usize, _PtFuncCompare: ?fn (?*c_void, ?*const c_void, ?*const c_void) callconv(.C) c_int, _Context: ?*c_void) void;
pub const struct__heapinfo = extern struct {
    _pentry: [*c]c_int,
    _size: usize,
    _useflag: c_int,
};
pub const _HEAPINFO = struct__heapinfo;
pub extern var _amblksiz: c_uint;
pub extern fn __mingw_aligned_malloc(_Size: usize, _Alignment: usize) ?*c_void;
pub extern fn __mingw_aligned_free(_Memory: ?*c_void) void;
pub extern fn __mingw_aligned_offset_realloc(_Memory: ?*c_void, _Size: usize, _Alignment: usize, _Offset: usize) ?*c_void;
pub extern fn __mingw_aligned_realloc(_Memory: ?*c_void, _Size: usize, _Offset: usize) ?*c_void;
pub fn _mm_malloc(arg___size: usize, arg___align: usize) callconv(.C) ?*c_void {
    var __size = arg___size;
    var __align = arg___align;
    if (__align == @bitCast(c_ulonglong, @as(c_longlong, @as(c_int, 1)))) {
        return malloc(__size);
    }
    if (!((__align & (__align -% @bitCast(c_ulonglong, @as(c_longlong, @as(c_int, 1))))) != 0) and (__align < @sizeOf(?*c_void))) {
        __align = @sizeOf(?*c_void);
    }
    var __mallocedMemory: ?*c_void = undefined;
    __mallocedMemory = __mingw_aligned_malloc(__size, __align);
    return __mallocedMemory;
}
pub fn _mm_free(arg___p: ?*c_void) callconv(.C) void {
    var __p = arg___p;
    __mingw_aligned_free(__p);
}
pub extern fn _resetstkoflw() c_int;
pub extern fn _set_malloc_crt_max_wait(_NewValue: c_ulong) c_ulong;
pub extern fn _expand(_Memory: ?*c_void, _NewSize: usize) ?*c_void;
pub extern fn _msize(_Memory: ?*c_void) usize;
pub extern fn _get_sbh_threshold() usize;
pub extern fn _set_sbh_threshold(_NewValue: usize) c_int;
pub extern fn _set_amblksiz(_Value: usize) errno_t;
pub extern fn _get_amblksiz(_Value: [*c]usize) errno_t;
pub extern fn _heapadd(_Memory: ?*c_void, _Size: usize) c_int;
pub extern fn _heapchk() c_int;
pub extern fn _heapmin() c_int;
pub extern fn _heapset(_Fill: c_uint) c_int;
pub extern fn _heapwalk(_EntryInfo: [*c]_HEAPINFO) c_int;
pub extern fn _heapused(_Used: [*c]usize, _Commit: [*c]usize) usize;
pub extern fn _get_heap_handle() isize;
pub fn _MarkAllocaS(arg__Ptr: ?*c_void, arg__Marker: c_uint) callconv(.C) ?*c_void {
    var _Ptr = arg__Ptr;
    var _Marker = arg__Marker;
    if (_Ptr != null) {
        @ptrCast([*c]c_uint, @alignCast(@import("std").meta.alignment(c_uint), _Ptr)).* = _Marker;
        _Ptr = @ptrCast(?*c_void, @ptrCast([*c]u8, @alignCast(@import("std").meta.alignment(u8), _Ptr)) + @bitCast(usize, @intCast(isize, @as(c_int, 16))));
    }
    return _Ptr;
}
pub fn _freea(arg__Memory: ?*c_void) callconv(.C) void {
    var _Memory = arg__Memory;
    var _Marker: c_uint = undefined;
    if (_Memory != null) {
        _Memory = @ptrCast(?*c_void, @ptrCast([*c]u8, @alignCast(@import("std").meta.alignment(u8), _Memory)) - @bitCast(usize, @intCast(isize, @as(c_int, 16))));
        _Marker = @ptrCast([*c]c_uint, @alignCast(@import("std").meta.alignment(c_uint), _Memory)).*;
        if (_Marker == @bitCast(c_uint, @as(c_int, 56797))) {
            free(_Memory);
        }
    }
}
pub extern fn _memccpy(_Dst: ?*c_void, _Src: ?*const c_void, _Val: c_int, _MaxCount: usize) ?*c_void;
pub extern fn memchr(_Buf: ?*const c_void, _Val: c_int, _MaxCount: c_ulonglong) ?*c_void;
pub extern fn _memicmp(_Buf1: ?*const c_void, _Buf2: ?*const c_void, _Size: usize) c_int;
pub extern fn _memicmp_l(_Buf1: ?*const c_void, _Buf2: ?*const c_void, _Size: usize, _Locale: _locale_t) c_int;
pub extern fn memcmp(_Buf1: ?*const c_void, _Buf2: ?*const c_void, _Size: c_ulonglong) c_int;
pub extern fn memcpy(_Dst: ?*c_void, _Src: ?*const c_void, _Size: c_ulonglong) ?*c_void;
pub extern fn memcpy_s(_dest: ?*c_void, _numberOfElements: usize, _src: ?*const c_void, _count: usize) errno_t;
pub extern fn mempcpy(_Dst: ?*c_void, _Src: ?*const c_void, _Size: c_ulonglong) ?*c_void;
pub extern fn memset(_Dst: ?*c_void, _Val: c_int, _Size: c_ulonglong) ?*c_void;
pub extern fn memccpy(_Dst: ?*c_void, _Src: ?*const c_void, _Val: c_int, _Size: c_ulonglong) ?*c_void;
pub extern fn memicmp(_Buf1: ?*const c_void, _Buf2: ?*const c_void, _Size: usize) c_int;
pub extern fn _strset(_Str: [*c]u8, _Val: c_int) [*c]u8;
pub extern fn _strset_l(_Str: [*c]u8, _Val: c_int, _Locale: _locale_t) [*c]u8;
pub extern fn strcpy(_Dest: [*c]u8, _Source: [*c]const u8) [*c]u8;
pub extern fn strcat(_Dest: [*c]u8, _Source: [*c]const u8) [*c]u8;
pub extern fn strcmp(_Str1: [*c]const u8, _Str2: [*c]const u8) c_int;
pub extern fn strlen(_Str: [*c]const u8) c_ulonglong;
pub extern fn strnlen(_Str: [*c]const u8, _MaxCount: usize) usize;
pub extern fn memmove(_Dst: ?*c_void, _Src: ?*const c_void, _Size: c_ulonglong) ?*c_void;
pub extern fn _strdup(_Src: [*c]const u8) [*c]u8;
pub extern fn strchr(_Str: [*c]const u8, _Val: c_int) [*c]u8;
pub extern fn _stricmp(_Str1: [*c]const u8, _Str2: [*c]const u8) c_int;
pub extern fn _strcmpi(_Str1: [*c]const u8, _Str2: [*c]const u8) c_int;
pub extern fn _stricmp_l(_Str1: [*c]const u8, _Str2: [*c]const u8, _Locale: _locale_t) c_int;
pub extern fn strcoll(_Str1: [*c]const u8, _Str2: [*c]const u8) c_int;
pub extern fn _strcoll_l(_Str1: [*c]const u8, _Str2: [*c]const u8, _Locale: _locale_t) c_int;
pub extern fn _stricoll(_Str1: [*c]const u8, _Str2: [*c]const u8) c_int;
pub extern fn _stricoll_l(_Str1: [*c]const u8, _Str2: [*c]const u8, _Locale: _locale_t) c_int;
pub extern fn _strncoll(_Str1: [*c]const u8, _Str2: [*c]const u8, _MaxCount: usize) c_int;
pub extern fn _strncoll_l(_Str1: [*c]const u8, _Str2: [*c]const u8, _MaxCount: usize, _Locale: _locale_t) c_int;
pub extern fn _strnicoll(_Str1: [*c]const u8, _Str2: [*c]const u8, _MaxCount: usize) c_int;
pub extern fn _strnicoll_l(_Str1: [*c]const u8, _Str2: [*c]const u8, _MaxCount: usize, _Locale: _locale_t) c_int;
pub extern fn strcspn(_Str: [*c]const u8, _Control: [*c]const u8) c_ulonglong;
pub extern fn _strerror(_ErrMsg: [*c]const u8) [*c]u8;
pub extern fn strerror(c_int) [*c]u8;
pub extern fn _strlwr(_String: [*c]u8) [*c]u8;
pub extern fn strlwr_l(_String: [*c]u8, _Locale: _locale_t) [*c]u8;
pub extern fn strncat(_Dest: [*c]u8, _Source: [*c]const u8, _Count: c_ulonglong) [*c]u8;
pub extern fn strncmp(_Str1: [*c]const u8, _Str2: [*c]const u8, _MaxCount: c_ulonglong) c_int;
pub extern fn _strnicmp(_Str1: [*c]const u8, _Str2: [*c]const u8, _MaxCount: usize) c_int;
pub extern fn _strnicmp_l(_Str1: [*c]const u8, _Str2: [*c]const u8, _MaxCount: usize, _Locale: _locale_t) c_int;
pub extern fn strncpy(_Dest: [*c]u8, _Source: [*c]const u8, _Count: c_ulonglong) [*c]u8;
pub extern fn _strnset(_Str: [*c]u8, _Val: c_int, _MaxCount: usize) [*c]u8;
pub extern fn _strnset_l(str: [*c]u8, c: c_int, count: usize, _Locale: _locale_t) [*c]u8;
pub extern fn strpbrk(_Str: [*c]const u8, _Control: [*c]const u8) [*c]u8;
pub extern fn strrchr(_Str: [*c]const u8, _Ch: c_int) [*c]u8;
pub extern fn _strrev(_Str: [*c]u8) [*c]u8;
pub extern fn strspn(_Str: [*c]const u8, _Control: [*c]const u8) c_ulonglong;
pub extern fn strstr(_Str: [*c]const u8, _SubStr: [*c]const u8) [*c]u8;
pub extern fn strtok(_Str: [*c]u8, _Delim: [*c]const u8) [*c]u8;
pub extern fn strtok_r(noalias _Str: [*c]u8, noalias _Delim: [*c]const u8, noalias __last: [*c][*c]u8) [*c]u8;
pub extern fn _strupr(_String: [*c]u8) [*c]u8;
pub extern fn _strupr_l(_String: [*c]u8, _Locale: _locale_t) [*c]u8;
pub extern fn strxfrm(_Dst: [*c]u8, _Src: [*c]const u8, _MaxCount: c_ulonglong) c_ulonglong;
pub extern fn _strxfrm_l(noalias _Dst: [*c]u8, noalias _Src: [*c]const u8, _MaxCount: usize, _Locale: _locale_t) usize;
pub extern fn strdup(_Src: [*c]const u8) [*c]u8;
pub extern fn strcmpi(_Str1: [*c]const u8, _Str2: [*c]const u8) c_int;
pub extern fn stricmp(_Str1: [*c]const u8, _Str2: [*c]const u8) c_int;
pub extern fn strlwr(_Str: [*c]u8) [*c]u8;
pub extern fn strnicmp(_Str1: [*c]const u8, _Str: [*c]const u8, _MaxCount: usize) c_int;
pub fn strncasecmp(arg___sz1: [*c]const u8, arg___sz2: [*c]const u8, arg___sizeMaxCompare: c_ulonglong) callconv(.C) c_int {
    var __sz1 = arg___sz1;
    var __sz2 = arg___sz2;
    var __sizeMaxCompare = arg___sizeMaxCompare;
    return _strnicmp(__sz1, __sz2, __sizeMaxCompare);
}
pub fn strcasecmp(arg___sz1: [*c]const u8, arg___sz2: [*c]const u8) callconv(.C) c_int {
    var __sz1 = arg___sz1;
    var __sz2 = arg___sz2;
    return _stricmp(__sz1, __sz2);
}
pub extern fn strnset(_Str: [*c]u8, _Val: c_int, _MaxCount: usize) [*c]u8;
pub extern fn strrev(_Str: [*c]u8) [*c]u8;
pub extern fn strset(_Str: [*c]u8, _Val: c_int) [*c]u8;
pub extern fn strupr(_Str: [*c]u8) [*c]u8;
pub extern fn _wcsdup(_Str: [*c]const wchar_t) [*c]wchar_t;
pub extern fn wcscat(noalias _Dest: [*c]wchar_t, noalias _Source: [*c]const wchar_t) [*c]wchar_t;
pub extern fn wcschr(_Str: [*c]const c_ushort, _Ch: c_ushort) [*c]c_ushort;
pub extern fn wcscmp(_Str1: [*c]const c_ushort, _Str2: [*c]const c_ushort) c_int;
pub extern fn wcscpy(noalias _Dest: [*c]wchar_t, noalias _Source: [*c]const wchar_t) [*c]wchar_t;
pub extern fn wcscspn(_Str: [*c]const wchar_t, _Control: [*c]const wchar_t) usize;
pub extern fn wcslen(_Str: [*c]const c_ushort) c_ulonglong;
pub extern fn wcsnlen(_Src: [*c]const wchar_t, _MaxCount: usize) usize;
pub extern fn wcsncat(noalias _Dest: [*c]wchar_t, noalias _Source: [*c]const wchar_t, _Count: usize) [*c]wchar_t;
pub extern fn wcsncmp(_Str1: [*c]const c_ushort, _Str2: [*c]const c_ushort, _MaxCount: c_ulonglong) c_int;
pub extern fn wcsncpy(noalias _Dest: [*c]wchar_t, noalias _Source: [*c]const wchar_t, _Count: usize) [*c]wchar_t;
pub extern fn _wcsncpy_l(noalias _Dest: [*c]wchar_t, noalias _Source: [*c]const wchar_t, _Count: usize, _Locale: _locale_t) [*c]wchar_t;
pub extern fn wcspbrk(_Str: [*c]const wchar_t, _Control: [*c]const wchar_t) [*c]wchar_t;
pub extern fn wcsrchr(_Str: [*c]const wchar_t, _Ch: wchar_t) [*c]wchar_t;
pub extern fn wcsspn(_Str: [*c]const wchar_t, _Control: [*c]const wchar_t) usize;
pub extern fn wcsstr(_Str: [*c]const wchar_t, _SubStr: [*c]const wchar_t) [*c]wchar_t;
pub extern fn wcstok(noalias _Str: [*c]wchar_t, noalias _Delim: [*c]const wchar_t) [*c]wchar_t;
pub extern fn _wcserror(_ErrNum: c_int) [*c]wchar_t;
pub extern fn __wcserror(_Str: [*c]const wchar_t) [*c]wchar_t;
pub extern fn _wcsicmp(_Str1: [*c]const wchar_t, _Str2: [*c]const wchar_t) c_int;
pub extern fn _wcsicmp_l(_Str1: [*c]const wchar_t, _Str2: [*c]const wchar_t, _Locale: _locale_t) c_int;
pub extern fn _wcsnicmp(_Str1: [*c]const wchar_t, _Str2: [*c]const wchar_t, _MaxCount: usize) c_int;
pub extern fn _wcsnicmp_l(_Str1: [*c]const wchar_t, _Str2: [*c]const wchar_t, _MaxCount: usize, _Locale: _locale_t) c_int;
pub extern fn _wcsnset(_Str: [*c]wchar_t, _Val: wchar_t, _MaxCount: usize) [*c]wchar_t;
pub extern fn _wcsrev(_Str: [*c]wchar_t) [*c]wchar_t;
pub extern fn _wcsset(_Str: [*c]wchar_t, _Val: wchar_t) [*c]wchar_t;
pub extern fn _wcslwr(_String: [*c]wchar_t) [*c]wchar_t;
pub extern fn _wcslwr_l(_String: [*c]wchar_t, _Locale: _locale_t) [*c]wchar_t;
pub extern fn _wcsupr(_String: [*c]wchar_t) [*c]wchar_t;
pub extern fn _wcsupr_l(_String: [*c]wchar_t, _Locale: _locale_t) [*c]wchar_t;
pub extern fn wcsxfrm(noalias _Dst: [*c]wchar_t, noalias _Src: [*c]const wchar_t, _MaxCount: usize) usize;
pub extern fn _wcsxfrm_l(noalias _Dst: [*c]wchar_t, noalias _Src: [*c]const wchar_t, _MaxCount: usize, _Locale: _locale_t) usize;
pub extern fn wcscoll(_Str1: [*c]const wchar_t, _Str2: [*c]const wchar_t) c_int;
pub extern fn _wcscoll_l(_Str1: [*c]const wchar_t, _Str2: [*c]const wchar_t, _Locale: _locale_t) c_int;
pub extern fn _wcsicoll(_Str1: [*c]const wchar_t, _Str2: [*c]const wchar_t) c_int;
pub extern fn _wcsicoll_l(_Str1: [*c]const wchar_t, _Str2: [*c]const wchar_t, _Locale: _locale_t) c_int;
pub extern fn _wcsncoll(_Str1: [*c]const wchar_t, _Str2: [*c]const wchar_t, _MaxCount: usize) c_int;
pub extern fn _wcsncoll_l(_Str1: [*c]const wchar_t, _Str2: [*c]const wchar_t, _MaxCount: usize, _Locale: _locale_t) c_int;
pub extern fn _wcsnicoll(_Str1: [*c]const wchar_t, _Str2: [*c]const wchar_t, _MaxCount: usize) c_int;
pub extern fn _wcsnicoll_l(_Str1: [*c]const wchar_t, _Str2: [*c]const wchar_t, _MaxCount: usize, _Locale: _locale_t) c_int;
pub extern fn wcsdup(_Str: [*c]const wchar_t) [*c]wchar_t;
pub extern fn wcsicmp(_Str1: [*c]const wchar_t, _Str2: [*c]const wchar_t) c_int;
pub extern fn wcsnicmp(_Str1: [*c]const wchar_t, _Str2: [*c]const wchar_t, _MaxCount: usize) c_int;
pub extern fn wcsnset(_Str: [*c]wchar_t, _Val: wchar_t, _MaxCount: usize) [*c]wchar_t;
pub extern fn wcsrev(_Str: [*c]wchar_t) [*c]wchar_t;
pub extern fn wcsset(_Str: [*c]wchar_t, _Val: wchar_t) [*c]wchar_t;
pub extern fn wcslwr(_Str: [*c]wchar_t) [*c]wchar_t;
pub extern fn wcsupr(_Str: [*c]wchar_t) [*c]wchar_t;
pub extern fn wcsicoll(_Str1: [*c]const wchar_t, _Str2: [*c]const wchar_t) c_int;
pub extern fn _strset_s(_Dst: [*c]u8, _DstSize: usize, _Value: c_int) errno_t;
pub extern fn _strerror_s(_Buf: [*c]u8, _SizeInBytes: usize, _ErrMsg: [*c]const u8) errno_t;
pub extern fn strerror_s(_Buf: [*c]u8, _SizeInBytes: usize, _ErrNum: c_int) errno_t;
pub extern fn _strlwr_s(_Str: [*c]u8, _Size: usize) errno_t;
pub extern fn _strlwr_s_l(_Str: [*c]u8, _Size: usize, _Locale: _locale_t) errno_t;
pub extern fn _strnset_s(_Str: [*c]u8, _Size: usize, _Val: c_int, _MaxCount: usize) errno_t;
pub extern fn _strupr_s(_Str: [*c]u8, _Size: usize) errno_t;
pub extern fn _strupr_s_l(_Str: [*c]u8, _Size: usize, _Locale: _locale_t) errno_t;
pub extern fn strncat_s(_Dst: [*c]u8, _DstSizeInChars: usize, _Src: [*c]const u8, _MaxCount: usize) errno_t;
pub extern fn _strncat_s_l(_Dst: [*c]u8, _DstSizeInChars: usize, _Src: [*c]const u8, _MaxCount: usize, _Locale: _locale_t) errno_t;
pub extern fn strcpy_s(_Dst: [*c]u8, _SizeInBytes: rsize_t, _Src: [*c]const u8) errno_t;
pub extern fn strncpy_s(_Dst: [*c]u8, _DstSizeInChars: usize, _Src: [*c]const u8, _MaxCount: usize) errno_t;
pub extern fn _strncpy_s_l(_Dst: [*c]u8, _DstSizeInChars: usize, _Src: [*c]const u8, _MaxCount: usize, _Locale: _locale_t) errno_t;
pub extern fn strtok_s(_Str: [*c]u8, _Delim: [*c]const u8, _Context: [*c][*c]u8) [*c]u8;
pub extern fn _strtok_s_l(_Str: [*c]u8, _Delim: [*c]const u8, _Context: [*c][*c]u8, _Locale: _locale_t) [*c]u8;
pub extern fn strcat_s(_Dst: [*c]u8, _SizeInBytes: rsize_t, _Src: [*c]const u8) errno_t;
pub fn strnlen_s(arg__src: [*c]const u8, arg__count: usize) callconv(.C) usize {
    var _src = arg__src;
    var _count = arg__count;
    return if (_src != null) strnlen(_src, _count) else @bitCast(c_ulonglong, @as(c_longlong, @as(c_int, 0)));
}
pub extern fn memmove_s(_dest: ?*c_void, _numberOfElements: usize, _src: ?*const c_void, _count: usize) errno_t;
pub extern fn wcstok_s(_Str: [*c]wchar_t, _Delim: [*c]const wchar_t, _Context: [*c][*c]wchar_t) [*c]wchar_t;
pub extern fn _wcserror_s(_Buf: [*c]wchar_t, _SizeInWords: usize, _ErrNum: c_int) errno_t;
pub extern fn __wcserror_s(_Buffer: [*c]wchar_t, _SizeInWords: usize, _ErrMsg: [*c]const wchar_t) errno_t;
pub extern fn _wcsnset_s(_Dst: [*c]wchar_t, _DstSizeInWords: usize, _Val: wchar_t, _MaxCount: usize) errno_t;
pub extern fn _wcsset_s(_Str: [*c]wchar_t, _SizeInWords: usize, _Val: wchar_t) errno_t;
pub extern fn _wcslwr_s(_Str: [*c]wchar_t, _SizeInWords: usize) errno_t;
pub extern fn _wcslwr_s_l(_Str: [*c]wchar_t, _SizeInWords: usize, _Locale: _locale_t) errno_t;
pub extern fn _wcsupr_s(_Str: [*c]wchar_t, _Size: usize) errno_t;
pub extern fn _wcsupr_s_l(_Str: [*c]wchar_t, _Size: usize, _Locale: _locale_t) errno_t;
pub extern fn wcscpy_s(_Dst: [*c]wchar_t, _SizeInWords: rsize_t, _Src: [*c]const wchar_t) errno_t;
pub extern fn wcscat_s(_Dst: [*c]wchar_t, _SizeInWords: rsize_t, _Src: [*c]const wchar_t) errno_t;
pub extern fn wcsncat_s(_Dst: [*c]wchar_t, _DstSizeInChars: usize, _Src: [*c]const wchar_t, _MaxCount: usize) errno_t;
pub extern fn _wcsncat_s_l(_Dst: [*c]wchar_t, _DstSizeInChars: usize, _Src: [*c]const wchar_t, _MaxCount: usize, _Locale: _locale_t) errno_t;
pub extern fn wcsncpy_s(_Dst: [*c]wchar_t, _DstSizeInChars: usize, _Src: [*c]const wchar_t, _MaxCount: usize) errno_t;
pub extern fn _wcsncpy_s_l(_Dst: [*c]wchar_t, _DstSizeInChars: usize, _Src: [*c]const wchar_t, _MaxCount: usize, _Locale: _locale_t) errno_t;
pub extern fn _wcstok_s_l(_Str: [*c]wchar_t, _Delim: [*c]const wchar_t, _Context: [*c][*c]wchar_t, _Locale: _locale_t) [*c]wchar_t;
pub extern fn _wcsset_s_l(_Str: [*c]wchar_t, _SizeInChars: usize, _Val: c_uint, _Locale: _locale_t) errno_t;
pub extern fn _wcsnset_s_l(_Str: [*c]wchar_t, _SizeInChars: usize, _Val: c_uint, _Count: usize, _Locale: _locale_t) errno_t;
pub fn wcsnlen_s(arg__src: [*c]const wchar_t, arg__count: usize) callconv(.C) usize {
    var _src = arg__src;
    var _count = arg__count;
    return if (_src != null) wcsnlen(_src, _count) else @bitCast(c_ulonglong, @as(c_longlong, @as(c_int, 0)));
}
pub extern fn _wassert(_Message: [*c]const wchar_t, _File: [*c]const wchar_t, _Line: c_uint) void;
pub extern fn _assert(_Message: [*c]const u8, _File: [*c]const u8, _Line: c_uint) void;
pub const max_align_t = extern struct {
    __clang_max_align_nonce1: c_longlong align(8),
    __clang_max_align_nonce2: c_longdouble align(16),
};
pub fn hashtable_internal_pow2ceil(arg_v: c_uint) callconv(.C) c_uint {
    var v = arg_v;
    v -%= 1;
    v |= v >> @intCast(@import("std").math.Log2Int(c_uint), 1);
    v |= v >> @intCast(@import("std").math.Log2Int(c_uint), 2);
    v |= v >> @intCast(@import("std").math.Log2Int(c_uint), 4);
    v |= v >> @intCast(@import("std").math.Log2Int(c_uint), 8);
    v |= v >> @intCast(@import("std").math.Log2Int(c_uint), 16);
    v +%= 1;
    v +%= @bitCast(c_uint, @boolToInt(v == @bitCast(c_uint, @as(c_int, 0))));
    return v;
}
pub fn hashtable_internal_calculate_hash(arg_key: c_ulonglong) callconv(.C) c_uint {
    var key = arg_key;
    key = ~key +% (key << @intCast(@import("std").math.Log2Int(c_ulonglong), 18));
    key = key ^ (key >> @intCast(@import("std").math.Log2Int(c_ulonglong), 31));
    key = key *% @bitCast(c_ulonglong, @as(c_longlong, @as(c_int, 21)));
    key = key ^ (key >> @intCast(@import("std").math.Log2Int(c_ulonglong), 11));
    key = key +% (key << @intCast(@import("std").math.Log2Int(c_ulonglong), 6));
    key = key ^ (key >> @intCast(@import("std").math.Log2Int(c_ulonglong), 22));
    _ = @as(c_int, 0);
    return @bitCast(c_uint, @truncate(c_uint, key));
}
pub fn hashtable_internal_find_slot(arg_table: [*c]const hashtable_t, arg_key: c_ulonglong) callconv(.C) c_int {
    var table = arg_table;
    var key = arg_key;
    const slot_mask: c_int = table.*.slot_capacity - @as(c_int, 1);
    const hash: c_uint = hashtable_internal_calculate_hash(key);
    const base_slot: c_int = @bitCast(c_int, hash & @bitCast(c_uint, slot_mask));
    var base_count: c_int = (blk: {
        const tmp = base_slot;
        if (tmp >= 0) break :blk table.*.slots + @intCast(usize, tmp) else break :blk table.*.slots - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
    }).*.base_count;
    var slot: c_int = base_slot;
    while (base_count > @as(c_int, 0)) {
        var slot_hash: c_uint = (blk: {
            const tmp = slot;
            if (tmp >= 0) break :blk table.*.slots + @intCast(usize, tmp) else break :blk table.*.slots - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
        }).*.key_hash;
        if (slot_hash != 0) {
            var slot_base: c_int = @bitCast(c_int, slot_hash & @bitCast(c_uint, slot_mask));
            if (slot_base == base_slot) {
                _ = @as(c_int, 0);
                base_count -= 1;
                if ((slot_hash == hash) and ((blk: {
                    const tmp = (blk_1: {
                        const tmp_2 = slot;
                        if (tmp_2 >= 0) break :blk_1 table.*.slots + @intCast(usize, tmp_2) else break :blk_1 table.*.slots - ~@bitCast(usize, @intCast(isize, tmp_2) +% -1);
                    }).*.item_index;
                    if (tmp >= 0) break :blk table.*.items_key + @intCast(usize, tmp) else break :blk table.*.items_key - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
                }).* == key)) return slot;
            }
        }
        slot = (slot + @as(c_int, 1)) & slot_mask;
    }
    return -@as(c_int, 1);
}
pub fn hashtable_internal_expand_slots(arg_table: [*c]hashtable_t) callconv(.C) void {
    var table = arg_table;
    const old_capacity: c_int = table.*.slot_capacity;
    var old_slots: [*c]struct_hashtable_internal_slot_t = table.*.slots;
    table.*.slot_capacity *= @as(c_int, 2);
    const slot_mask: c_int = table.*.slot_capacity - @as(c_int, 1);
    const size: c_int = @bitCast(c_int, @truncate(c_uint, @bitCast(c_ulonglong, @as(c_longlong, table.*.slot_capacity)) *% @sizeOf(struct_hashtable_internal_slot_t)));
    table.*.slots = @ptrCast([*c]struct_hashtable_internal_slot_t, @alignCast(@import("std").meta.alignment(struct_hashtable_internal_slot_t), malloc(@bitCast(usize, @as(c_longlong, size)))));
    _ = @as(c_int, 0);
    _ = memset(@ptrCast(?*c_void, table.*.slots), @as(c_int, 0), @bitCast(usize, @as(c_longlong, size)));
    {
        var i: c_int = 0;
        while (i < old_capacity) : (i += 1) {
            const hash: c_uint = (blk: {
                const tmp = i;
                if (tmp >= 0) break :blk old_slots + @intCast(usize, tmp) else break :blk old_slots - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
            }).*.key_hash;
            if (hash != 0) {
                const base_slot: c_int = @bitCast(c_int, hash & @bitCast(c_uint, slot_mask));
                var slot: c_int = base_slot;
                while ((blk: {
                    const tmp = slot;
                    if (tmp >= 0) break :blk table.*.slots + @intCast(usize, tmp) else break :blk table.*.slots - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
                }).*.key_hash != 0) {
                    slot = (slot + @as(c_int, 1)) & slot_mask;
                }
                (blk: {
                    const tmp = slot;
                    if (tmp >= 0) break :blk table.*.slots + @intCast(usize, tmp) else break :blk table.*.slots - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
                }).*.key_hash = hash;
                var item_index: c_int = (blk: {
                    const tmp = i;
                    if (tmp >= 0) break :blk old_slots + @intCast(usize, tmp) else break :blk old_slots - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
                }).*.item_index;
                (blk: {
                    const tmp = slot;
                    if (tmp >= 0) break :blk table.*.slots + @intCast(usize, tmp) else break :blk table.*.slots - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
                }).*.item_index = item_index;
                (blk: {
                    const tmp = item_index;
                    if (tmp >= 0) break :blk table.*.items_slot + @intCast(usize, tmp) else break :blk table.*.items_slot - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
                }).* = slot;
                (blk: {
                    const tmp = base_slot;
                    if (tmp >= 0) break :blk table.*.slots + @intCast(usize, tmp) else break :blk table.*.slots - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
                }).*.base_count += 1;
            }
        }
    }
    free(@ptrCast(?*c_void, old_slots));
}
pub fn hashtable_internal_expand_items(arg_table: [*c]hashtable_t) callconv(.C) void {
    var table = arg_table;
    table.*.item_capacity *= @as(c_int, 2);
    const new_items_key: [*c]c_ulonglong = @ptrCast([*c]c_ulonglong, @alignCast(@import("std").meta.alignment(c_ulonglong), malloc((@bitCast(c_ulonglong, @as(c_longlong, table.*.item_capacity)) *% ((@sizeOf(c_ulonglong) +% @sizeOf(c_int)) +% @bitCast(c_ulonglong, @as(c_longlong, table.*.item_size)))) +% @bitCast(c_ulonglong, @as(c_longlong, table.*.item_size)))));
    _ = @as(c_int, 0);
    const new_items_slot: [*c]c_int = @ptrCast([*c]c_int, @alignCast(@import("std").meta.alignment(c_int), new_items_key + @bitCast(usize, @intCast(isize, table.*.item_capacity))));
    const new_items_data: ?*c_void = @ptrCast(?*c_void, new_items_slot + @bitCast(usize, @intCast(isize, table.*.item_capacity)));
    const new_swap_temp: ?*c_void = @intToPtr(?*c_void, @intCast(usize, @ptrToInt(new_items_data)) +% @bitCast(c_ulonglong, @as(c_longlong, table.*.item_size * table.*.item_capacity)));
    _ = memcpy(@ptrCast(?*c_void, new_items_key), @ptrCast(?*const c_void, table.*.items_key), @bitCast(c_ulonglong, @as(c_longlong, table.*.count)) *% @sizeOf(c_ulonglong));
    _ = memcpy(@ptrCast(?*c_void, new_items_slot), @ptrCast(?*const c_void, table.*.items_slot), @bitCast(c_ulonglong, @as(c_longlong, table.*.count)) *% @sizeOf(c_ulonglong));
    _ = memcpy(new_items_data, table.*.items_data, @bitCast(usize, @as(c_longlong, table.*.count)) *% @bitCast(c_ulonglong, @as(c_longlong, table.*.item_size)));
    free(@ptrCast(?*c_void, table.*.items_key));
    table.*.items_key = new_items_key;
    table.*.items_slot = new_items_slot;
    table.*.items_data = new_items_data;
    table.*.swap_temp = new_swap_temp;
}
pub export fn sprite_batch_internal_use_scratch_buffer(arg_sb: [*c]spritebatch_t) bool {
    var sb = arg_sb;
    return sb.*.sprites_sorter_callback == null;
}
pub export fn spritebatch_internal_lonely_sprite(arg_sb: [*c]spritebatch_t, arg_image_id: c_ulonglong, arg_w: c_int, arg_h: c_int, arg_sprite_out: [*c]spritebatch_sprite_t, arg_skip_missing_textures: c_int) c_int {
    var sb = arg_sb;
    var image_id = arg_image_id;
    var w = arg_w;
    var h = arg_h;
    var sprite_out = arg_sprite_out;
    var skip_missing_textures = arg_skip_missing_textures;
    var tex: [*c]spritebatch_internal_lonely_texture_t = @ptrCast([*c]spritebatch_internal_lonely_texture_t, @alignCast(@import("std").meta.alignment(spritebatch_internal_lonely_texture_t), hashtable_find(&sb.*.sprites_to_lonely_textures, image_id)));
    if (skip_missing_textures != 0) {
        if (!(tex != null)) {
            _ = spritebatch_internal_lonelybuffer_push(sb, image_id, w, h, @as(c_int, 0));
        }
        return 1;
    } else {
        if (!(tex != null)) {
            tex = spritebatch_internal_lonelybuffer_push(sb, image_id, w, h, @as(c_int, 1));
        } else if (tex.*.texture_id == @bitCast(c_ulonglong, @as(c_longlong, ~@as(c_int, 0)))) {
            tex.*.texture_id = spritebatch_internal_generate_texture_handle(sb, image_id, w, h);
        }
        tex.*.timestamp = 0;
        if (sprite_out != null) {
            sprite_out.*.texture_id = tex.*.texture_id;
            sprite_out.*.minx = blk: {
                const tmp = @intToFloat(f32, @as(c_int, 0));
                sprite_out.*.miny = tmp;
                break :blk tmp;
            };
            sprite_out.*.maxx = blk: {
                const tmp = 1.0;
                sprite_out.*.maxy = tmp;
                break :blk tmp;
            };
            if (true) {
                var tmp: f32 = sprite_out.*.miny;
                sprite_out.*.miny = sprite_out.*.maxy;
                sprite_out.*.maxy = tmp;
            }
        }
        return 0;
    }
    return 0;
}
pub fn spritebatch_internal_sprite_less_than_or_equal(arg_a: [*c]spritebatch_sprite_t, arg_b: [*c]spritebatch_sprite_t) callconv(.C) c_int {
    var a = arg_a;
    var b = arg_b;
    if (a.*.sort_bits < b.*.sort_bits) return 1;
    if ((a.*.sort_bits == b.*.sort_bits) and (a.*.texture_id <= b.*.texture_id)) return 1;
    return 0;
}
pub export fn spritebatch_internal_merge_sort_iteration(arg_a: [*c]spritebatch_sprite_t, arg_lo: c_int, arg_split: c_int, arg_hi: c_int, arg_b: [*c]spritebatch_sprite_t) void {
    var a = arg_a;
    var lo = arg_lo;
    var split = arg_split;
    var hi = arg_hi;
    var b = arg_b;
    var i: c_int = lo;
    var j: c_int = split;
    {
        var k: c_int = lo;
        while (k < hi) : (k += 1) {
            if ((i < split) and ((j >= hi) or (spritebatch_internal_sprite_less_than_or_equal(a + @bitCast(usize, @intCast(isize, i)), a + @bitCast(usize, @intCast(isize, j))) != 0))) {
                (blk: {
                    const tmp = k;
                    if (tmp >= 0) break :blk b + @intCast(usize, tmp) else break :blk b - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
                }).* = (blk: {
                    const tmp = i;
                    if (tmp >= 0) break :blk a + @intCast(usize, tmp) else break :blk a - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
                }).*;
                i = i + @as(c_int, 1);
            } else {
                (blk: {
                    const tmp = k;
                    if (tmp >= 0) break :blk b + @intCast(usize, tmp) else break :blk b - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
                }).* = (blk: {
                    const tmp = j;
                    if (tmp >= 0) break :blk a + @intCast(usize, tmp) else break :blk a - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
                }).*;
                j = j + @as(c_int, 1);
            }
        }
    }
}
pub export fn spritebatch_internal_merge_sort_recurse(arg_b: [*c]spritebatch_sprite_t, arg_lo: c_int, arg_hi: c_int, arg_a: [*c]spritebatch_sprite_t) void {
    var b = arg_b;
    var lo = arg_lo;
    var hi = arg_hi;
    var a = arg_a;
    if ((hi - lo) <= @as(c_int, 1)) return;
    var split: c_int = @divTrunc(lo + hi, @as(c_int, 2));
    spritebatch_internal_merge_sort_recurse(a, lo, split, b);
    spritebatch_internal_merge_sort_recurse(a, split, hi, b);
    spritebatch_internal_merge_sort_iteration(b, lo, split, hi, a);
}
pub export fn spritebatch_internal_merge_sort(arg_a: [*c]spritebatch_sprite_t, arg_b: [*c]spritebatch_sprite_t, arg_n: c_int) void {
    var a = arg_a;
    var b = arg_b;
    var n = arg_n;
    _ = memcpy(@ptrCast(?*c_void, b), @ptrCast(?*const c_void, a), @sizeOf(spritebatch_sprite_t) *% @bitCast(c_ulonglong, @as(c_longlong, n)));
    spritebatch_internal_merge_sort_recurse(b, @as(c_int, 0), n, a);
}
pub export fn spritebatch_internal_sort_sprites(arg_sb: [*c]spritebatch_t) void {
    var sb = arg_sb;
    if (sb.*.sprites_sorter_callback != null) {
        sb.*.sprites_sorter_callback.?(sb.*.sprites, sb.*.sprite_count);
    } else {
        spritebatch_internal_merge_sort(sb.*.sprites, sb.*.sprites_scratch, sb.*.sprite_count);
    }
}
pub fn spritebatch_internal_get_pixels(arg_sb: [*c]spritebatch_t, arg_image_id: c_ulonglong, arg_w: c_int, arg_h: c_int) callconv(.C) void {
    var sb = arg_sb;
    var image_id = arg_image_id;
    var w = arg_w;
    var h = arg_h;
    var size: c_int = if (sb.*.atlas_use_border_pixels != 0) (sb.*.pixel_stride * (w + @as(c_int, 2))) * (h + @as(c_int, 2)) else (sb.*.pixel_stride * w) * h;
    if (size > sb.*.pixel_buffer_size) {
        free(sb.*.pixel_buffer);
        sb.*.pixel_buffer_size = size;
        sb.*.pixel_buffer = malloc(@bitCast(c_ulonglong, @as(c_longlong, sb.*.pixel_buffer_size)));
        if (!(sb.*.pixel_buffer != null)) return;
    }
    _ = memset(sb.*.pixel_buffer, @as(c_int, 0), @bitCast(c_ulonglong, @as(c_longlong, size)));
    var size_from_user: c_int = (sb.*.pixel_stride * w) * h;
    sb.*.get_pixels_callback.?(image_id, sb.*.pixel_buffer, size_from_user, sb.*.udata);
    if (sb.*.atlas_use_border_pixels != 0) {
        var w0: c_int = w;
        var h0: c_int = h;
        w += @as(c_int, 2);
        h += @as(c_int, 2);
        var buffer: [*c]u8 = @ptrCast([*c]u8, @alignCast(@import("std").meta.alignment(u8), sb.*.pixel_buffer));
        var dst_row_stride: c_int = w * sb.*.pixel_stride;
        var src_row_stride: c_int = w0 * sb.*.pixel_stride;
        var src_row_offset: c_int = sb.*.pixel_stride;
        {
            var i: c_int = 0;
            while (i < (h - @as(c_int, 2))) : (i += 1) {
                var src_row: [*c]u8 = buffer + @bitCast(usize, @intCast(isize, ((h0 - i) - @as(c_int, 1)) * src_row_stride));
                var dst_row: [*c]u8 = (buffer + @bitCast(usize, @intCast(isize, ((h - i) - @as(c_int, 2)) * dst_row_stride))) + @bitCast(usize, @intCast(isize, src_row_offset));
                _ = memmove(@ptrCast(?*c_void, dst_row), @ptrCast(?*const c_void, src_row), @bitCast(c_ulonglong, @as(c_longlong, src_row_stride)));
            }
        }
        var pixel_stride: c_int = sb.*.pixel_stride;
        _ = memset(@ptrCast(?*c_void, buffer), @as(c_int, 0), @bitCast(c_ulonglong, @as(c_longlong, dst_row_stride)));
        {
            var i: c_int = 1;
            while (i < (h - @as(c_int, 1))) : (i += 1) {
                _ = memset(@ptrCast(?*c_void, buffer + @bitCast(usize, @intCast(isize, i * dst_row_stride))), @as(c_int, 0), @bitCast(c_ulonglong, @as(c_longlong, pixel_stride)));
                _ = memset(@ptrCast(?*c_void, ((buffer + @bitCast(usize, @intCast(isize, i * dst_row_stride))) + @bitCast(usize, @intCast(isize, src_row_stride))) + @bitCast(usize, @intCast(isize, src_row_offset))), @as(c_int, 0), @bitCast(c_ulonglong, @as(c_longlong, pixel_stride)));
            }
        }
        _ = memset(@ptrCast(?*c_void, buffer + @bitCast(usize, @intCast(isize, (h - @as(c_int, 1)) * dst_row_stride))), @as(c_int, 0), @bitCast(c_ulonglong, @as(c_longlong, dst_row_stride)));
    }
}
pub fn spritebatch_internal_generate_texture_handle(arg_sb: [*c]spritebatch_t, arg_image_id: c_ulonglong, arg_w: c_int, arg_h: c_int) callconv(.C) c_ulonglong {
    var sb = arg_sb;
    var image_id = arg_image_id;
    var w = arg_w;
    var h = arg_h;
    spritebatch_internal_get_pixels(sb, image_id, w, h);
    if (sb.*.atlas_use_border_pixels != 0) {
        w += @as(c_int, 2);
        h += @as(c_int, 2);
    }
    return sb.*.generate_texture_callback.?(sb.*.pixel_buffer, w, h, sb.*.udata);
}
pub export fn spritebatch_internal_lonelybuffer_push(arg_sb: [*c]spritebatch_t, arg_image_id: c_ulonglong, arg_w: c_int, arg_h: c_int, arg_make_tex: c_int) [*c]spritebatch_internal_lonely_texture_t {
    var sb = arg_sb;
    var image_id = arg_image_id;
    var w = arg_w;
    var h = arg_h;
    var make_tex = arg_make_tex;
    var texture: spritebatch_internal_lonely_texture_t = undefined;
    texture.timestamp = 0;
    texture.w = w;
    texture.h = h;
    texture.image_id = image_id;
    texture.texture_id = if (make_tex != 0) spritebatch_internal_generate_texture_handle(sb, image_id, w, h) else @bitCast(c_ulonglong, @as(c_longlong, ~@as(c_int, 0)));
    return @ptrCast([*c]spritebatch_internal_lonely_texture_t, @alignCast(@import("std").meta.alignment(spritebatch_internal_lonely_texture_t), hashtable_insert(&sb.*.sprites_to_lonely_textures, image_id, @ptrCast(?*const c_void, &texture))));
}
pub export fn spritebatch_internal_push_sprite(arg_sb: [*c]spritebatch_t, arg_s: [*c]spritebatch_internal_sprite_t, arg_skip_missing_textures: c_int) c_int {
    var sb = arg_sb;
    var s = arg_s;
    var skip_missing_textures = arg_skip_missing_textures;
    var skipped_tex: c_int = 0;
    var sprite: spritebatch_sprite_t = undefined;
    sprite.image_id = s.*.image_id;
    sprite.sort_bits = s.*.sort_bits;
    sprite.x = s.*.x;
    sprite.y = s.*.y;
    sprite.w = s.*.w;
    sprite.h = s.*.h;
    sprite.sx = s.*.sx;
    sprite.sy = s.*.sy;
    sprite.c = s.*.c;
    sprite.s = s.*.s;
    var atlas_ptr: ?*c_void = hashtable_find(&sb.*.sprites_to_atlases, s.*.image_id);
    if (atlas_ptr != null) {
        var atlas: [*c]spritebatch_internal_atlas_t = @ptrCast([*c][*c]spritebatch_internal_atlas_t, @alignCast(@import("std").meta.alignment([*c]spritebatch_internal_atlas_t), atlas_ptr)).*;
        sprite.texture_id = atlas.*.texture_id;
        var tex: [*c]spritebatch_internal_texture_t = @ptrCast([*c]spritebatch_internal_texture_t, @alignCast(@import("std").meta.alignment(spritebatch_internal_texture_t), hashtable_find(&atlas.*.sprites_to_textures, s.*.image_id)));
        _ = @as(c_int, 0);
        tex.*.timestamp = 0;
        sprite.w = tex.*.w;
        sprite.h = tex.*.h;
        sprite.minx = tex.*.minx;
        sprite.miny = tex.*.miny;
        sprite.maxx = tex.*.maxx;
        sprite.maxy = tex.*.maxy;
    } else {
        skipped_tex = spritebatch_internal_lonely_sprite(sb, s.*.image_id, s.*.w, s.*.h, &sprite, skip_missing_textures);
    }
    if (!(skipped_tex != 0)) {
        if (sb.*.sprite_count >= sb.*.sprite_capacity) {
            var new_capacity: c_int = sb.*.sprite_capacity * @as(c_int, 2);
            var new_data: ?*c_void = malloc(@sizeOf(spritebatch_sprite_t) *% @bitCast(c_ulonglong, @as(c_longlong, new_capacity)));
            if (!(new_data != null)) return 0;
            _ = memcpy(new_data, @ptrCast(?*const c_void, sb.*.sprites), @sizeOf(spritebatch_sprite_t) *% @bitCast(c_ulonglong, @as(c_longlong, sb.*.sprite_count)));
            free(@ptrCast(?*c_void, sb.*.sprites));
            sb.*.sprites = @ptrCast([*c]spritebatch_sprite_t, @alignCast(@import("std").meta.alignment(spritebatch_sprite_t), new_data));
            sb.*.sprite_capacity = new_capacity;
            if (sb.*.sprites_scratch != null) {
                free(@ptrCast(?*c_void, sb.*.sprites_scratch));
            }
            if (sprite_batch_internal_use_scratch_buffer(sb)) {
                sb.*.sprites_scratch = @ptrCast([*c]spritebatch_sprite_t, @alignCast(@import("std").meta.alignment(spritebatch_sprite_t), malloc(@sizeOf(spritebatch_sprite_t) *% @bitCast(c_ulonglong, @as(c_longlong, new_capacity)))));
            }
        }
        (blk: {
            const tmp = blk_1: {
                const ref = &sb.*.sprite_count;
                const tmp_2 = ref.*;
                ref.* += 1;
                break :blk_1 tmp_2;
            };
            if (tmp >= 0) break :blk sb.*.sprites + @intCast(usize, tmp) else break :blk sb.*.sprites - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
        }).* = sprite;
    }
    return skipped_tex;
}
pub export fn spritebatch_internal_process_input(arg_sb: [*c]spritebatch_t, arg_skip_missing_textures: c_int) void {
    var sb = arg_sb;
    var skip_missing_textures = arg_skip_missing_textures;
    var skipped_index: c_int = 0;
    {
        var i: c_int = 0;
        while (i < sb.*.input_count) : (i += 1) {
            var s: [*c]spritebatch_internal_sprite_t = sb.*.input_buffer + @bitCast(usize, @intCast(isize, i));
            var skipped: c_int = spritebatch_internal_push_sprite(sb, s, skip_missing_textures);
            if ((skip_missing_textures != 0) and (skipped != 0)) {
                (blk: {
                    const tmp = blk_1: {
                        const ref = &skipped_index;
                        const tmp_2 = ref.*;
                        ref.* += 1;
                        break :blk_1 tmp_2;
                    };
                    if (tmp >= 0) break :blk sb.*.input_buffer + @intCast(usize, tmp) else break :blk sb.*.input_buffer - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
                }).* = s.*;
            }
        }
    }
    sb.*.input_count = skipped_index;
}
pub const spritebatch_v2_t = extern struct {
    x: c_int,
    y: c_int,
};
pub const spritebatch_internal_integer_image_t = extern struct {
    img_index: c_int,
    size: spritebatch_v2_t,
    min: spritebatch_v2_t,
    max: spritebatch_v2_t,
    fit: c_int,
};
pub fn spritebatch_v2(arg_x: c_int, arg_y: c_int) callconv(.C) spritebatch_v2_t {
    var x = arg_x;
    var y = arg_y;
    var v: spritebatch_v2_t = undefined;
    v.x = x;
    v.y = y;
    return v;
}
pub fn spritebatch_sub(arg_a: spritebatch_v2_t, arg_b: spritebatch_v2_t) callconv(.C) spritebatch_v2_t {
    var a = arg_a;
    var b = arg_b;
    var v: spritebatch_v2_t = undefined;
    v.x = a.x - b.x;
    v.y = a.y - b.y;
    return v;
}
pub fn spritebatch_add(arg_a: spritebatch_v2_t, arg_b: spritebatch_v2_t) callconv(.C) spritebatch_v2_t {
    var a = arg_a;
    var b = arg_b;
    var v: spritebatch_v2_t = undefined;
    v.x = a.x + b.x;
    v.y = a.y + b.y;
    return v;
}
pub const spritebatch_internal_atlas_node_t = extern struct {
    size: spritebatch_v2_t,
    min: spritebatch_v2_t,
    max: spritebatch_v2_t,
};
pub fn spritebatch_best_fit(arg_sp: c_int, arg_w: c_int, arg_h: c_int, arg_nodes: [*c]spritebatch_internal_atlas_node_t) callconv(.C) [*c]spritebatch_internal_atlas_node_t {
    var sp = arg_sp;
    var w = arg_w;
    var h = arg_h;
    var nodes = arg_nodes;
    var best_volume: c_int = 2147483647;
    var best_node: [*c]spritebatch_internal_atlas_node_t = null;
    var img_volume: c_int = w * h;
    {
        var i: c_int = 0;
        while (i < sp) : (i += 1) {
            var node: [*c]spritebatch_internal_atlas_node_t = nodes + @bitCast(usize, @intCast(isize, i));
            var can_contain: c_int = @boolToInt((node.*.size.x >= w) and (node.*.size.y >= h));
            if (can_contain != 0) {
                var node_volume: c_int = node.*.size.x * node.*.size.y;
                if (node_volume == img_volume) return node;
                if (node_volume < best_volume) {
                    best_volume = node_volume;
                    best_node = node;
                }
            }
        }
    }
    return best_node;
}
pub fn spritebatch_internal_image_less_than_or_equal(arg_a: [*c]spritebatch_internal_integer_image_t, arg_b: [*c]spritebatch_internal_integer_image_t) callconv(.C) c_int {
    var a = arg_a;
    var b = arg_b;
    var perimeterA: c_int = @as(c_int, 2) * (a.*.size.x + a.*.size.y);
    var perimeterB: c_int = @as(c_int, 2) * (b.*.size.x + b.*.size.y);
    return @boolToInt(perimeterB <= perimeterA);
}
pub export fn spritebatch_internal_image_merge_sort_iteration(arg_a: [*c]spritebatch_internal_integer_image_t, arg_lo: c_int, arg_split: c_int, arg_hi: c_int, arg_b: [*c]spritebatch_internal_integer_image_t) void {
    var a = arg_a;
    var lo = arg_lo;
    var split = arg_split;
    var hi = arg_hi;
    var b = arg_b;
    var i: c_int = lo;
    var j: c_int = split;
    {
        var k: c_int = lo;
        while (k < hi) : (k += 1) {
            if ((i < split) and ((j >= hi) or (spritebatch_internal_image_less_than_or_equal(a + @bitCast(usize, @intCast(isize, i)), a + @bitCast(usize, @intCast(isize, j))) != 0))) {
                (blk: {
                    const tmp = k;
                    if (tmp >= 0) break :blk b + @intCast(usize, tmp) else break :blk b - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
                }).* = (blk: {
                    const tmp = i;
                    if (tmp >= 0) break :blk a + @intCast(usize, tmp) else break :blk a - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
                }).*;
                i = i + @as(c_int, 1);
            } else {
                (blk: {
                    const tmp = k;
                    if (tmp >= 0) break :blk b + @intCast(usize, tmp) else break :blk b - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
                }).* = (blk: {
                    const tmp = j;
                    if (tmp >= 0) break :blk a + @intCast(usize, tmp) else break :blk a - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
                }).*;
                j = j + @as(c_int, 1);
            }
        }
    }
}
pub export fn spritebatch_internal_image_merge_sort_recurse(arg_b: [*c]spritebatch_internal_integer_image_t, arg_lo: c_int, arg_hi: c_int, arg_a: [*c]spritebatch_internal_integer_image_t) void {
    var b = arg_b;
    var lo = arg_lo;
    var hi = arg_hi;
    var a = arg_a;
    if ((hi - lo) <= @as(c_int, 1)) return;
    var split: c_int = @divTrunc(lo + hi, @as(c_int, 2));
    spritebatch_internal_image_merge_sort_recurse(a, lo, split, b);
    spritebatch_internal_image_merge_sort_recurse(a, split, hi, b);
    spritebatch_internal_image_merge_sort_iteration(b, lo, split, hi, a);
}
pub export fn spritebatch_internal_image_merge_sort(arg_a: [*c]spritebatch_internal_integer_image_t, arg_b: [*c]spritebatch_internal_integer_image_t, arg_n: c_int) void {
    var a = arg_a;
    var b = arg_b;
    var n = arg_n;
    _ = memcpy(@ptrCast(?*c_void, b), @ptrCast(?*const c_void, a), @sizeOf(spritebatch_internal_integer_image_t) *% @bitCast(c_ulonglong, @as(c_longlong, n)));
    spritebatch_internal_image_merge_sort_recurse(b, @as(c_int, 0), n, a);
}
pub const spritebatch_internal_atlas_image_t = extern struct {
    img_index: c_int,
    w: c_int,
    h: c_int,
    minx: f32,
    miny: f32,
    maxx: f32,
    maxy: f32,
    fit: c_int,
}; // ./cute_spritebatch.h:1554:74: warning: TODO implement translation of stmt class GotoStmtClass
// ./cute_spritebatch.h:1556:6: warning: unable to translate function, demoted to extern
pub extern fn spritebatch_make_atlas(arg_sb: [*c]spritebatch_t, arg_atlas_out: [*c]spritebatch_internal_atlas_t, arg_imgs: [*c]const spritebatch_internal_lonely_texture_t, arg_img_count: c_int) void;
pub fn spritebatch_internal_lonely_pred(arg_a: [*c]spritebatch_internal_lonely_texture_t, arg_b: [*c]spritebatch_internal_lonely_texture_t) callconv(.C) c_int {
    var a = arg_a;
    var b = arg_b;
    return @boolToInt(a.*.timestamp < b.*.timestamp);
}
pub fn spritebatch_internal_qsort_lonely(arg_lonely_table: [*c]hashtable_t, arg_items: [*c]spritebatch_internal_lonely_texture_t, arg_count: c_int) callconv(.C) void {
    var lonely_table = arg_lonely_table;
    var items = arg_items;
    var count = arg_count;
    if (count <= @as(c_int, 1)) return;
    var pivot: spritebatch_internal_lonely_texture_t = (blk: {
        const tmp = count - @as(c_int, 1);
        if (tmp >= 0) break :blk items + @intCast(usize, tmp) else break :blk items - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
    }).*;
    var low: c_int = 0;
    {
        var i: c_int = 0;
        while (i < (count - @as(c_int, 1))) : (i += 1) {
            if (spritebatch_internal_lonely_pred(items + @bitCast(usize, @intCast(isize, i)), &pivot) != 0) {
                hashtable_swap(lonely_table, i, low);
                low += 1;
            }
        }
    }
    hashtable_swap(lonely_table, low, count - @as(c_int, 1));
    spritebatch_internal_qsort_lonely(lonely_table, items, low);
    spritebatch_internal_qsort_lonely(lonely_table, (items + @bitCast(usize, @intCast(isize, low))) + @bitCast(usize, @intCast(isize, @as(c_int, 1))), (count - @as(c_int, 1)) - low);
}
pub export fn spritebatch_internal_buffer_key(arg_sb: [*c]spritebatch_t, arg_key: c_ulonglong) c_int {
    var sb = arg_sb;
    var key = arg_key;
    {
        if (sb.*.key_buffer_count == sb.*.key_buffer_capacity) {
            var new_capacity: c_int = sb.*.key_buffer_capacity * @as(c_int, 2);
            var new_data: ?*c_void = malloc(@sizeOf(c_ulonglong) *% @bitCast(c_ulonglong, @as(c_longlong, new_capacity)));
            if (!(new_data != null)) return 0;
            _ = memcpy(new_data, @ptrCast(?*const c_void, sb.*.key_buffer), @sizeOf(c_ulonglong) *% @bitCast(c_ulonglong, @as(c_longlong, sb.*.key_buffer_count)));
            free(@ptrCast(?*c_void, sb.*.key_buffer));
            sb.*.key_buffer = @ptrCast([*c]c_ulonglong, @alignCast(@import("std").meta.alignment(c_ulonglong), new_data));
            sb.*.key_buffer_capacity = new_capacity;
        }
    }
    (blk: {
        const tmp = blk_1: {
            const ref = &sb.*.key_buffer_count;
            const tmp_2 = ref.*;
            ref.* += 1;
            break :blk_1 tmp_2;
        };
        if (tmp >= 0) break :blk sb.*.key_buffer + @intCast(usize, tmp) else break :blk sb.*.key_buffer - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
    }).* = key;
    return 0;
}
pub export fn spritebatch_internal_remove_table_entries(arg_sb: [*c]spritebatch_t, arg_table: [*c]hashtable_t) void {
    var sb = arg_sb;
    var table = arg_table;
    {
        var i: c_int = 0;
        while (i < sb.*.key_buffer_count) : (i += 1) {
            hashtable_remove(table, (blk: {
                const tmp = i;
                if (tmp >= 0) break :blk sb.*.key_buffer + @intCast(usize, tmp) else break :blk sb.*.key_buffer - ~@bitCast(usize, @intCast(isize, tmp) +% -1);
            }).*);
        }
    }
    sb.*.key_buffer_count = 0;
}
pub export fn spritebatch_internal_flush_atlas(arg_sb: [*c]spritebatch_t, arg_atlas: [*c]spritebatch_internal_atlas_t, arg_sentinel: [*c][*c]spritebatch_internal_atlas_t, arg_next: [*c][*c]spritebatch_internal_atlas_t) void {
    var sb = arg_sb;
    var atlas = arg_atlas;
    var sentinel = arg_sentinel;
    var next = arg_next;
    var ticks_to_decay_texture: c_int = sb.*.ticks_to_decay_texture;
    var texture_count: c_int = hashtable_count(&atlas.*.sprites_to_textures);
    var textures: [*c]spritebatch_internal_texture_t = @ptrCast([*c]spritebatch_internal_texture_t, @alignCast(@import("std").meta.alignment(spritebatch_internal_texture_t), hashtable_items(&atlas.*.sprites_to_textures)));
    {
        var i: c_int = 0;
        while (i < texture_count) : (i += 1) {
            var atlas_texture: [*c]spritebatch_internal_texture_t = textures + @bitCast(usize, @intCast(isize, i));
            if (atlas_texture.*.timestamp < ticks_to_decay_texture) {
                var w: c_int = atlas_texture.*.w;
                var h: c_int = atlas_texture.*.h;
                if (sb.*.atlas_use_border_pixels != 0) {
                    w -= @as(c_int, 2);
                    h -= @as(c_int, 2);
                }
                var lonely_texture: [*c]spritebatch_internal_lonely_texture_t = spritebatch_internal_lonelybuffer_push(sb, atlas_texture.*.image_id, w, h, @as(c_int, 0));
                lonely_texture.*.timestamp = atlas_texture.*.timestamp;
            }
            hashtable_remove(&sb.*.sprites_to_atlases, atlas_texture.*.image_id);
        }
    }
    if (sb.*.atlases == atlas) {
        if (atlas.*.next == atlas) {
            sb.*.atlases = null;
        } else {
            sb.*.atlases = atlas.*.prev;
        }
    }
    if ((sentinel != null) and (next != null)) {
        if (sentinel.* == atlas) {
            if (next.*.*.next != sentinel.*) {
                next.* = next.*.*.next;
            }
            sentinel.* = next.*;
        }
    }
    atlas.*.next.*.prev = atlas.*.prev;
    atlas.*.prev.*.next = atlas.*.next;
    hashtable_term(&atlas.*.sprites_to_textures);
    sb.*.delete_texture_callback.?(atlas.*.texture_id, sb.*.udata);
    free(@ptrCast(?*c_void, atlas));
}
pub export fn spritebatch_internal_log_chain(arg_atlas: [*c]spritebatch_internal_atlas_t) void {
    var atlas = arg_atlas;
    if (atlas != null) {
        var sentinel: [*c]spritebatch_internal_atlas_t = atlas;
        while (true) {
            var next: [*c]spritebatch_internal_atlas_t = atlas.*.next;
            atlas = next;
            if (!(atlas != sentinel)) break;
        }
    }
}
pub const __STRINGIFY = @compileError("unable to translate C expr: unexpected token .Hash"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any/_mingw_mac.h:10:9
pub const __MINGW64_VERSION_STR = @compileError("unable to translate C expr: unexpected token .StringLiteral"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any/_mingw_mac.h:26:9
pub const __MINGW_IMP_SYMBOL = @compileError("unable to translate C expr: unexpected token .HashHash"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any/_mingw_mac.h:119:11
pub const __MINGW_IMP_LSYMBOL = @compileError("unable to translate C expr: unexpected token .HashHash"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any/_mingw_mac.h:120:11
pub const __MINGW_LSYMBOL = @compileError("unable to translate C expr: unexpected token .HashHash"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any/_mingw_mac.h:122:11
pub const __MINGW_POISON_NAME = @compileError("unable to translate C expr: unexpected token .HashHash"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any/_mingw_mac.h:203:11
pub const __MSABI_LONG = @compileError("unable to translate C expr: unexpected token .HashHash"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any/_mingw_mac.h:209:13
pub const __MINGW_ATTRIB_DEPRECATED_STR = @compileError("unable to translate C expr: unexpected token .Eof"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any/_mingw_mac.h:247:11
pub const __mingw_ovr = @compileError("unable to translate C expr: unexpected token .Keyword_static"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any/_mingw_mac.h:289:11
pub const __MINGW_CRT_NAME_CONCAT2 = @compileError("unable to translate C expr: unexpected token .Colon"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any/_mingw_secapi.h:41:9
pub const __CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES_MEMORY_0_3_ = @compileError("unable to translate C expr: unexpected token .Identifier"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any/_mingw_secapi.h:69:9
pub const __MINGW_IMPORT = @compileError("unable to translate C expr: unexpected token .Keyword_extern"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\_mingw.h:51:12
pub const __CRT_INLINE = @compileError("unable to translate C expr: unexpected token .Keyword_extern"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\_mingw.h:90:11
pub const __MINGW_INTRIN_INLINE = @compileError("unable to translate C expr: unexpected token .Keyword_extern"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\_mingw.h:97:9
pub const __MINGW_PRAGMA_PARAM = @compileError("unable to translate C expr: unexpected token .Eof"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\_mingw.h:215:9
pub const __MINGW_BROKEN_INTERFACE = @compileError("unable to translate C expr: expected ',' or ')'"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\_mingw.h:218:9
pub const __forceinline = @compileError("unable to translate C expr: unexpected token .Keyword_extern"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\_mingw.h:267:9
pub const _crt_va_start = @compileError("TODO implement function '__builtin_va_start' in std.zig.c_builtins"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\vadefs.h:48:9
pub const _crt_va_arg = @compileError("TODO implement function '__builtin_va_arg' in std.zig.c_builtins"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\vadefs.h:49:9
pub const _crt_va_end = @compileError("TODO implement function '__builtin_va_end' in std.zig.c_builtins"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\vadefs.h:50:9
pub const _crt_va_copy = @compileError("TODO implement function '__builtin_va_copy' in std.zig.c_builtins"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\vadefs.h:51:9
pub const __CRT_STRINGIZE = @compileError("unable to translate C expr: unexpected token .Hash"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\_mingw.h:286:9
pub const __CRT_WIDE = @compileError("unable to translate C expr: unexpected token .HashHash"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\_mingw.h:291:9
pub const _CRT_INSECURE_DEPRECATE_MEMORY = @compileError("unable to translate C expr: unexpected token .Eof"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\_mingw.h:353:9
pub const _CRT_INSECURE_DEPRECATE_GLOBALS = @compileError("unable to translate C expr: unexpected token .Eof"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\_mingw.h:357:9
pub const _CRT_OBSOLETE = @compileError("unable to translate C expr: unexpected token .Eof"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\_mingw.h:365:9
pub const _UNION_NAME = @compileError("unable to translate C expr: unexpected token .Eof"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\_mingw.h:476:9
pub const _STRUCT_NAME = @compileError("unable to translate C expr: unexpected token .Eof"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\_mingw.h:477:9
pub const __CRT_UUID_DECL = @compileError("unable to translate C expr: unexpected token .Eof"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\_mingw.h:564:9
pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_0 = @compileError("unable to translate C expr: unexpected token .Eof"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\corecrt.h:267:9
pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_1 = @compileError("unable to translate C expr: unexpected token .Eof"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\corecrt.h:268:9
pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_2 = @compileError("unable to translate C expr: unexpected token .Eof"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\corecrt.h:269:9
pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_3 = @compileError("unable to translate C expr: unexpected token .Eof"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\corecrt.h:270:9
pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_4 = @compileError("unable to translate C expr: unexpected token .Eof"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\corecrt.h:271:9
pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_1_1 = @compileError("unable to translate C expr: unexpected token .Eof"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\corecrt.h:272:9
pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_1_2 = @compileError("unable to translate C expr: unexpected token .Eof"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\corecrt.h:273:9
pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_1_3 = @compileError("unable to translate C expr: unexpected token .Eof"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\corecrt.h:274:9
pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_2_0 = @compileError("unable to translate C expr: unexpected token .Eof"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\corecrt.h:275:9
pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_1_ARGLIST = @compileError("unable to translate C expr: unexpected token .Eof"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\corecrt.h:276:9
pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_2_ARGLIST = @compileError("unable to translate C expr: unexpected token .Eof"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\corecrt.h:277:9
pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_SPLITPATH = @compileError("unable to translate C expr: unexpected token .Eof"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\corecrt.h:278:9
pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_0 = @compileError("unable to translate C expr: expected ',' or ')'"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\corecrt.h:282:9
pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_1 = @compileError("unable to translate C expr: expected ',' or ')'"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\corecrt.h:284:9
pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_2 = @compileError("unable to translate C expr: expected ',' or ')'"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\corecrt.h:286:9
pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_3 = @compileError("unable to translate C expr: expected ',' or ')'"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\corecrt.h:288:9
pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_4 = @compileError("unable to translate C expr: expected ',' or ')'"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\corecrt.h:290:9
pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_0_EX = @compileError("unable to translate C expr: unexpected token .Eof"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\corecrt.h:427:9
pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_1_EX = @compileError("unable to translate C expr: unexpected token .Eof"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\corecrt.h:428:9
pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_2_EX = @compileError("unable to translate C expr: unexpected token .Eof"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\corecrt.h:429:9
pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_3_EX = @compileError("unable to translate C expr: unexpected token .Eof"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\corecrt.h:430:9
pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_4_EX = @compileError("unable to translate C expr: unexpected token .Eof"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\corecrt.h:431:9
pub const __crt_typefix = @compileError("unable to translate C expr: unexpected token .Eof"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\corecrt.h:491:9
pub const _countof = @compileError("unable to translate C expr: expected ')'"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\stdlib.h:377:9
pub const _STATIC_ASSERT = @compileError("unable to translate C expr: unexpected token .Keyword_extern"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\malloc.h:27:9
pub const _alloca = @compileError("TODO implement function '__builtin_alloca' in std.zig.c_builtins"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\malloc.h:93:9
pub const alloca = @compileError("TODO implement function '__builtin_alloca' in std.zig.c_builtins"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\malloc.h:159:9
pub const static_assert = @compileError("unable to translate C expr: unexpected token .Keyword_static_assert"); // C:\Users\valer\Desktop\PATATINO\zig\lib\libc\include\any-windows-any\assert.h:38:9
pub const SPRITEBATCH_LOG = @compileError("unable to translate C expr: expected ')'"); // ./cute_spritebatch.h:526:11
pub const offsetof = @compileError("TODO implement function '__builtin_offsetof' in std.zig.c_builtins"); // C:\Users\valer\Desktop\PATATINO\zig\lib\include\stddef.h:104:9
pub const SPRITEBATCH_CHECK_BUFFER_GROW = @compileError("unable to translate C expr: unexpected token .Keyword_do"); // ./cute_spritebatch.h:1074:9
pub const SPRITEBATCH_CHECK = @compileError("unable to translate C expr: unexpected token .Keyword_do"); // ./cute_spritebatch.h:1554:9
pub const __llvm__ = @as(c_int, 1);
pub const __clang__ = @as(c_int, 1);
pub const __clang_major__ = @as(c_int, 12);
pub const __clang_minor__ = @as(c_int, 0);
pub const __clang_patchlevel__ = @as(c_int, 1);
pub const __clang_version__ = "12.0.1 (https://github.com/llvm/llvm-project 328a6ec955327c6d56b6bc3478c723dd3cd468ef)";
pub const __GNUC__ = @as(c_int, 4);
pub const __GNUC_MINOR__ = @as(c_int, 2);
pub const __GNUC_PATCHLEVEL__ = @as(c_int, 1);
pub const __GXX_ABI_VERSION = @as(c_int, 1002);
pub const __ATOMIC_RELAXED = @as(c_int, 0);
pub const __ATOMIC_CONSUME = @as(c_int, 1);
pub const __ATOMIC_ACQUIRE = @as(c_int, 2);
pub const __ATOMIC_RELEASE = @as(c_int, 3);
pub const __ATOMIC_ACQ_REL = @as(c_int, 4);
pub const __ATOMIC_SEQ_CST = @as(c_int, 5);
pub const __OPENCL_MEMORY_SCOPE_WORK_ITEM = @as(c_int, 0);
pub const __OPENCL_MEMORY_SCOPE_WORK_GROUP = @as(c_int, 1);
pub const __OPENCL_MEMORY_SCOPE_DEVICE = @as(c_int, 2);
pub const __OPENCL_MEMORY_SCOPE_ALL_SVM_DEVICES = @as(c_int, 3);
pub const __OPENCL_MEMORY_SCOPE_SUB_GROUP = @as(c_int, 4);
pub const __PRAGMA_REDEFINE_EXTNAME = @as(c_int, 1);
pub const __VERSION__ = "Clang 12.0.1 (https://github.com/llvm/llvm-project 328a6ec955327c6d56b6bc3478c723dd3cd468ef)";
pub const __OBJC_BOOL_IS_BOOL = @as(c_int, 0);
pub const __CONSTANT_CFSTRINGS__ = @as(c_int, 1);
pub const __SEH__ = @as(c_int, 1);
pub const __OPTIMIZE__ = @as(c_int, 1);
pub const __ORDER_LITTLE_ENDIAN__ = @as(c_int, 1234);
pub const __ORDER_BIG_ENDIAN__ = @as(c_int, 4321);
pub const __ORDER_PDP_ENDIAN__ = @as(c_int, 3412);
pub const __BYTE_ORDER__ = __ORDER_LITTLE_ENDIAN__;
pub const __LITTLE_ENDIAN__ = @as(c_int, 1);
pub const __CHAR_BIT__ = @as(c_int, 8);
pub const __SCHAR_MAX__ = @as(c_int, 127);
pub const __SHRT_MAX__ = @as(c_int, 32767);
pub const __INT_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __LONG_MAX__ = @as(c_long, 2147483647);
pub const __LONG_LONG_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __WCHAR_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
pub const __WINT_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
pub const __INTMAX_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __SIZE_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const __UINTMAX_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const __PTRDIFF_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __INTPTR_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __UINTPTR_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const __SIZEOF_DOUBLE__ = @as(c_int, 8);
pub const __SIZEOF_FLOAT__ = @as(c_int, 4);
pub const __SIZEOF_INT__ = @as(c_int, 4);
pub const __SIZEOF_LONG__ = @as(c_int, 4);
pub const __SIZEOF_LONG_DOUBLE__ = @as(c_int, 16);
pub const __SIZEOF_LONG_LONG__ = @as(c_int, 8);
pub const __SIZEOF_POINTER__ = @as(c_int, 8);
pub const __SIZEOF_SHORT__ = @as(c_int, 2);
pub const __SIZEOF_PTRDIFF_T__ = @as(c_int, 8);
pub const __SIZEOF_SIZE_T__ = @as(c_int, 8);
pub const __SIZEOF_WCHAR_T__ = @as(c_int, 2);
pub const __SIZEOF_WINT_T__ = @as(c_int, 2);
pub const __SIZEOF_INT128__ = @as(c_int, 16);
pub const __INTMAX_TYPE__ = c_longlong;
pub const __INTMAX_FMTd__ = "lld";
pub const __INTMAX_FMTi__ = "lli";
pub const __INTMAX_C_SUFFIX__ = LL;
pub const __UINTMAX_TYPE__ = c_ulonglong;
pub const __UINTMAX_FMTo__ = "llo";
pub const __UINTMAX_FMTu__ = "llu";
pub const __UINTMAX_FMTx__ = "llx";
pub const __UINTMAX_FMTX__ = "llX";
pub const __UINTMAX_C_SUFFIX__ = ULL;
pub const __INTMAX_WIDTH__ = @as(c_int, 64);
pub const __PTRDIFF_TYPE__ = c_longlong;
pub const __PTRDIFF_FMTd__ = "lld";
pub const __PTRDIFF_FMTi__ = "lli";
pub const __PTRDIFF_WIDTH__ = @as(c_int, 64);
pub const __INTPTR_TYPE__ = c_longlong;
pub const __INTPTR_FMTd__ = "lld";
pub const __INTPTR_FMTi__ = "lli";
pub const __INTPTR_WIDTH__ = @as(c_int, 64);
pub const __SIZE_TYPE__ = c_ulonglong;
pub const __SIZE_FMTo__ = "llo";
pub const __SIZE_FMTu__ = "llu";
pub const __SIZE_FMTx__ = "llx";
pub const __SIZE_FMTX__ = "llX";
pub const __SIZE_WIDTH__ = @as(c_int, 64);
pub const __WCHAR_TYPE__ = c_ushort;
pub const __WCHAR_WIDTH__ = @as(c_int, 16);
pub const __WINT_TYPE__ = c_ushort;
pub const __WINT_WIDTH__ = @as(c_int, 16);
pub const __SIG_ATOMIC_WIDTH__ = @as(c_int, 32);
pub const __SIG_ATOMIC_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __CHAR16_TYPE__ = c_ushort;
pub const __CHAR32_TYPE__ = c_uint;
pub const __UINTMAX_WIDTH__ = @as(c_int, 64);
pub const __UINTPTR_TYPE__ = c_ulonglong;
pub const __UINTPTR_FMTo__ = "llo";
pub const __UINTPTR_FMTu__ = "llu";
pub const __UINTPTR_FMTx__ = "llx";
pub const __UINTPTR_FMTX__ = "llX";
pub const __UINTPTR_WIDTH__ = @as(c_int, 64);
pub const __FLT_DENORM_MIN__ = @as(f32, 1.40129846e-45);
pub const __FLT_HAS_DENORM__ = @as(c_int, 1);
pub const __FLT_DIG__ = @as(c_int, 6);
pub const __FLT_DECIMAL_DIG__ = @as(c_int, 9);
pub const __FLT_EPSILON__ = @as(f32, 1.19209290e-7);
pub const __FLT_HAS_INFINITY__ = @as(c_int, 1);
pub const __FLT_HAS_QUIET_NAN__ = @as(c_int, 1);
pub const __FLT_MANT_DIG__ = @as(c_int, 24);
pub const __FLT_MAX_10_EXP__ = @as(c_int, 38);
pub const __FLT_MAX_EXP__ = @as(c_int, 128);
pub const __FLT_MAX__ = @as(f32, 3.40282347e+38);
pub const __FLT_MIN_10_EXP__ = -@as(c_int, 37);
pub const __FLT_MIN_EXP__ = -@as(c_int, 125);
pub const __FLT_MIN__ = @as(f32, 1.17549435e-38);
pub const __DBL_DENORM_MIN__ = 4.9406564584124654e-324;
pub const __DBL_HAS_DENORM__ = @as(c_int, 1);
pub const __DBL_DIG__ = @as(c_int, 15);
pub const __DBL_DECIMAL_DIG__ = @as(c_int, 17);
pub const __DBL_EPSILON__ = 2.2204460492503131e-16;
pub const __DBL_HAS_INFINITY__ = @as(c_int, 1);
pub const __DBL_HAS_QUIET_NAN__ = @as(c_int, 1);
pub const __DBL_MANT_DIG__ = @as(c_int, 53);
pub const __DBL_MAX_10_EXP__ = @as(c_int, 308);
pub const __DBL_MAX_EXP__ = @as(c_int, 1024);
pub const __DBL_MAX__ = 1.7976931348623157e+308;
pub const __DBL_MIN_10_EXP__ = -@as(c_int, 307);
pub const __DBL_MIN_EXP__ = -@as(c_int, 1021);
pub const __DBL_MIN__ = 2.2250738585072014e-308;
pub const __LDBL_DENORM_MIN__ = @as(c_longdouble, 3.64519953188247460253e-4951);
pub const __LDBL_HAS_DENORM__ = @as(c_int, 1);
pub const __LDBL_DIG__ = @as(c_int, 18);
pub const __LDBL_DECIMAL_DIG__ = @as(c_int, 21);
pub const __LDBL_EPSILON__ = @as(c_longdouble, 1.08420217248550443401e-19);
pub const __LDBL_HAS_INFINITY__ = @as(c_int, 1);
pub const __LDBL_HAS_QUIET_NAN__ = @as(c_int, 1);
pub const __LDBL_MANT_DIG__ = @as(c_int, 64);
pub const __LDBL_MAX_10_EXP__ = @as(c_int, 4932);
pub const __LDBL_MAX_EXP__ = @as(c_int, 16384);
pub const __LDBL_MAX__ = @as(c_longdouble, 1.18973149535723176502e+4932);
pub const __LDBL_MIN_10_EXP__ = -@as(c_int, 4931);
pub const __LDBL_MIN_EXP__ = -@as(c_int, 16381);
pub const __LDBL_MIN__ = @as(c_longdouble, 3.36210314311209350626e-4932);
pub const __POINTER_WIDTH__ = @as(c_int, 64);
pub const __BIGGEST_ALIGNMENT__ = @as(c_int, 16);
pub const __WCHAR_UNSIGNED__ = @as(c_int, 1);
pub const __WINT_UNSIGNED__ = @as(c_int, 1);
pub const __INT8_TYPE__ = i8;
pub const __INT8_FMTd__ = "hhd";
pub const __INT8_FMTi__ = "hhi";
pub const __INT16_TYPE__ = c_short;
pub const __INT16_FMTd__ = "hd";
pub const __INT16_FMTi__ = "hi";
pub const __INT32_TYPE__ = c_int;
pub const __INT32_FMTd__ = "d";
pub const __INT32_FMTi__ = "i";
pub const __INT64_TYPE__ = c_longlong;
pub const __INT64_FMTd__ = "lld";
pub const __INT64_FMTi__ = "lli";
pub const __INT64_C_SUFFIX__ = LL;
pub const __UINT8_TYPE__ = u8;
pub const __UINT8_FMTo__ = "hho";
pub const __UINT8_FMTu__ = "hhu";
pub const __UINT8_FMTx__ = "hhx";
pub const __UINT8_FMTX__ = "hhX";
pub const __UINT8_MAX__ = @as(c_int, 255);
pub const __INT8_MAX__ = @as(c_int, 127);
pub const __UINT16_TYPE__ = c_ushort;
pub const __UINT16_FMTo__ = "ho";
pub const __UINT16_FMTu__ = "hu";
pub const __UINT16_FMTx__ = "hx";
pub const __UINT16_FMTX__ = "hX";
pub const __UINT16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
pub const __INT16_MAX__ = @as(c_int, 32767);
pub const __UINT32_TYPE__ = c_uint;
pub const __UINT32_FMTo__ = "o";
pub const __UINT32_FMTu__ = "u";
pub const __UINT32_FMTx__ = "x";
pub const __UINT32_FMTX__ = "X";
pub const __UINT32_C_SUFFIX__ = U;
pub const __UINT32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __INT32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __UINT64_TYPE__ = c_ulonglong;
pub const __UINT64_FMTo__ = "llo";
pub const __UINT64_FMTu__ = "llu";
pub const __UINT64_FMTx__ = "llx";
pub const __UINT64_FMTX__ = "llX";
pub const __UINT64_C_SUFFIX__ = ULL;
pub const __UINT64_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const __INT64_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __INT_LEAST8_TYPE__ = i8;
pub const __INT_LEAST8_MAX__ = @as(c_int, 127);
pub const __INT_LEAST8_FMTd__ = "hhd";
pub const __INT_LEAST8_FMTi__ = "hhi";
pub const __UINT_LEAST8_TYPE__ = u8;
pub const __UINT_LEAST8_MAX__ = @as(c_int, 255);
pub const __UINT_LEAST8_FMTo__ = "hho";
pub const __UINT_LEAST8_FMTu__ = "hhu";
pub const __UINT_LEAST8_FMTx__ = "hhx";
pub const __UINT_LEAST8_FMTX__ = "hhX";
pub const __INT_LEAST16_TYPE__ = c_short;
pub const __INT_LEAST16_MAX__ = @as(c_int, 32767);
pub const __INT_LEAST16_FMTd__ = "hd";
pub const __INT_LEAST16_FMTi__ = "hi";
pub const __UINT_LEAST16_TYPE__ = c_ushort;
pub const __UINT_LEAST16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
pub const __UINT_LEAST16_FMTo__ = "ho";
pub const __UINT_LEAST16_FMTu__ = "hu";
pub const __UINT_LEAST16_FMTx__ = "hx";
pub const __UINT_LEAST16_FMTX__ = "hX";
pub const __INT_LEAST32_TYPE__ = c_int;
pub const __INT_LEAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __INT_LEAST32_FMTd__ = "d";
pub const __INT_LEAST32_FMTi__ = "i";
pub const __UINT_LEAST32_TYPE__ = c_uint;
pub const __UINT_LEAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __UINT_LEAST32_FMTo__ = "o";
pub const __UINT_LEAST32_FMTu__ = "u";
pub const __UINT_LEAST32_FMTx__ = "x";
pub const __UINT_LEAST32_FMTX__ = "X";
pub const __INT_LEAST64_TYPE__ = c_longlong;
pub const __INT_LEAST64_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __INT_LEAST64_FMTd__ = "lld";
pub const __INT_LEAST64_FMTi__ = "lli";
pub const __UINT_LEAST64_TYPE__ = c_ulonglong;
pub const __UINT_LEAST64_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const __UINT_LEAST64_FMTo__ = "llo";
pub const __UINT_LEAST64_FMTu__ = "llu";
pub const __UINT_LEAST64_FMTx__ = "llx";
pub const __UINT_LEAST64_FMTX__ = "llX";
pub const __INT_FAST8_TYPE__ = i8;
pub const __INT_FAST8_MAX__ = @as(c_int, 127);
pub const __INT_FAST8_FMTd__ = "hhd";
pub const __INT_FAST8_FMTi__ = "hhi";
pub const __UINT_FAST8_TYPE__ = u8;
pub const __UINT_FAST8_MAX__ = @as(c_int, 255);
pub const __UINT_FAST8_FMTo__ = "hho";
pub const __UINT_FAST8_FMTu__ = "hhu";
pub const __UINT_FAST8_FMTx__ = "hhx";
pub const __UINT_FAST8_FMTX__ = "hhX";
pub const __INT_FAST16_TYPE__ = c_short;
pub const __INT_FAST16_MAX__ = @as(c_int, 32767);
pub const __INT_FAST16_FMTd__ = "hd";
pub const __INT_FAST16_FMTi__ = "hi";
pub const __UINT_FAST16_TYPE__ = c_ushort;
pub const __UINT_FAST16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
pub const __UINT_FAST16_FMTo__ = "ho";
pub const __UINT_FAST16_FMTu__ = "hu";
pub const __UINT_FAST16_FMTx__ = "hx";
pub const __UINT_FAST16_FMTX__ = "hX";
pub const __INT_FAST32_TYPE__ = c_int;
pub const __INT_FAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __INT_FAST32_FMTd__ = "d";
pub const __INT_FAST32_FMTi__ = "i";
pub const __UINT_FAST32_TYPE__ = c_uint;
pub const __UINT_FAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __UINT_FAST32_FMTo__ = "o";
pub const __UINT_FAST32_FMTu__ = "u";
pub const __UINT_FAST32_FMTx__ = "x";
pub const __UINT_FAST32_FMTX__ = "X";
pub const __INT_FAST64_TYPE__ = c_longlong;
pub const __INT_FAST64_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __INT_FAST64_FMTd__ = "lld";
pub const __INT_FAST64_FMTi__ = "lli";
pub const __UINT_FAST64_TYPE__ = c_ulonglong;
pub const __UINT_FAST64_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const __UINT_FAST64_FMTo__ = "llo";
pub const __UINT_FAST64_FMTu__ = "llu";
pub const __UINT_FAST64_FMTx__ = "llx";
pub const __UINT_FAST64_FMTX__ = "llX";
pub const __FINITE_MATH_ONLY__ = @as(c_int, 0);
pub const __GNUC_STDC_INLINE__ = @as(c_int, 1);
pub const __GCC_ATOMIC_TEST_AND_SET_TRUEVAL = @as(c_int, 1);
pub const __CLANG_ATOMIC_BOOL_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_CHAR_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_CHAR16_T_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_CHAR32_T_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_WCHAR_T_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_SHORT_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_INT_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_LONG_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_LLONG_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_POINTER_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_BOOL_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_CHAR_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_CHAR16_T_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_CHAR32_T_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_WCHAR_T_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_SHORT_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_INT_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_LONG_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_LLONG_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_POINTER_LOCK_FREE = @as(c_int, 2);
pub const __PIC__ = @as(c_int, 2);
pub const __pic__ = @as(c_int, 2);
pub const __FLT_EVAL_METHOD__ = @as(c_int, 0);
pub const __FLT_RADIX__ = @as(c_int, 2);
pub const __DECIMAL_DIG__ = __LDBL_DECIMAL_DIG__;
pub const __GCC_ASM_FLAG_OUTPUTS__ = @as(c_int, 1);
pub const __code_model_small__ = @as(c_int, 1);
pub const __amd64__ = @as(c_int, 1);
pub const __amd64 = @as(c_int, 1);
pub const __x86_64 = @as(c_int, 1);
pub const __x86_64__ = @as(c_int, 1);
pub const __SEG_GS = @as(c_int, 1);
pub const __SEG_FS = @as(c_int, 1);
pub const __seg_gs = __attribute__(address_space(@as(c_int, 256)));
pub const __seg_fs = __attribute__(address_space(@as(c_int, 257)));
pub const __corei7 = @as(c_int, 1);
pub const __corei7__ = @as(c_int, 1);
pub const __tune_corei7__ = @as(c_int, 1);
pub const __NO_MATH_INLINES = @as(c_int, 1);
pub const __AES__ = @as(c_int, 1);
pub const __PCLMUL__ = @as(c_int, 1);
pub const __LAHF_SAHF__ = @as(c_int, 1);
pub const __LZCNT__ = @as(c_int, 1);
pub const __RDRND__ = @as(c_int, 1);
pub const __FSGSBASE__ = @as(c_int, 1);
pub const __BMI__ = @as(c_int, 1);
pub const __BMI2__ = @as(c_int, 1);
pub const __POPCNT__ = @as(c_int, 1);
pub const __PRFCHW__ = @as(c_int, 1);
pub const __RDSEED__ = @as(c_int, 1);
pub const __ADX__ = @as(c_int, 1);
pub const __MOVBE__ = @as(c_int, 1);
pub const __FMA__ = @as(c_int, 1);
pub const __F16C__ = @as(c_int, 1);
pub const __FXSR__ = @as(c_int, 1);
pub const __XSAVE__ = @as(c_int, 1);
pub const __XSAVEOPT__ = @as(c_int, 1);
pub const __XSAVEC__ = @as(c_int, 1);
pub const __XSAVES__ = @as(c_int, 1);
pub const __CLFLUSHOPT__ = @as(c_int, 1);
pub const __SGX__ = @as(c_int, 1);
pub const __INVPCID__ = @as(c_int, 1);
pub const __AVX2__ = @as(c_int, 1);
pub const __AVX__ = @as(c_int, 1);
pub const __SSE4_2__ = @as(c_int, 1);
pub const __SSE4_1__ = @as(c_int, 1);
pub const __SSSE3__ = @as(c_int, 1);
pub const __SSE3__ = @as(c_int, 1);
pub const __SSE2__ = @as(c_int, 1);
pub const __SSE2_MATH__ = @as(c_int, 1);
pub const __SSE__ = @as(c_int, 1);
pub const __SSE_MATH__ = @as(c_int, 1);
pub const __MMX__ = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_1 = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_4 = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_8 = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_16 = @as(c_int, 1);
pub const __SIZEOF_FLOAT128__ = @as(c_int, 16);
pub const _WIN32 = @as(c_int, 1);
pub const _WIN64 = @as(c_int, 1);
pub const WIN32 = @as(c_int, 1);
pub const __WIN32 = @as(c_int, 1);
pub const __WIN32__ = @as(c_int, 1);
pub const WINNT = @as(c_int, 1);
pub const __WINNT = @as(c_int, 1);
pub const __WINNT__ = @as(c_int, 1);
pub const WIN64 = @as(c_int, 1);
pub const __WIN64 = @as(c_int, 1);
pub const __WIN64__ = @as(c_int, 1);
pub const __MINGW64__ = @as(c_int, 1);
pub const __MSVCRT__ = @as(c_int, 1);
pub const __MINGW32__ = @as(c_int, 1);
pub inline fn __declspec(a: anytype) @TypeOf(__attribute__(a)) {
    return __attribute__(a);
}
pub const _cdecl = __attribute__(__cdecl__);
pub const __cdecl = __attribute__(__cdecl__);
pub const _stdcall = __attribute__(__stdcall__);
pub const __stdcall = __attribute__(__stdcall__);
pub const _fastcall = __attribute__(__fastcall__);
pub const __fastcall = __attribute__(__fastcall__);
pub const _thiscall = __attribute__(__thiscall__);
pub const __thiscall = __attribute__(__thiscall__);
pub const _pascal = __attribute__(__pascal__);
pub const __pascal = __attribute__(__pascal__);
pub const __STDC__ = @as(c_int, 1);
pub const __STDC_HOSTED__ = @as(c_int, 1);
pub const __STDC_VERSION__ = @as(c_long, 201710);
pub const __STDC_UTF_16__ = @as(c_int, 1);
pub const __STDC_UTF_32__ = @as(c_int, 1);
pub const NDEBUG = @as(c_int, 1);
pub const bool_2 = bool;
pub const true_3 = @as(c_int, 1);
pub const false_4 = @as(c_int, 0);
pub const __bool_true_false_are_defined = @as(c_int, 1);
pub const SPRITEBATCH_U64 = c_ulonglong;
pub const HASHTABLE_U64 = c_ulonglong;
pub const HASHTABLE_U32 = c_uint;
pub inline fn __MINGW64_STRINGIFY(x: anytype) @TypeOf(__STRINGIFY(x)) {
    return __STRINGIFY(x);
}
pub const __MINGW64_VERSION_MAJOR = @as(c_int, 9);
pub const __MINGW64_VERSION_MINOR = @as(c_int, 0);
pub const __MINGW64_VERSION_BUGFIX = @as(c_int, 0);
pub const __MINGW64_VERSION_RC = @as(c_int, 0);
pub const __MINGW64_VERSION_STATE = "alpha";
pub const __MINGW32_MAJOR_VERSION = @as(c_int, 3);
pub const __MINGW32_MINOR_VERSION = @as(c_int, 11);
pub const _M_AMD64 = @as(c_int, 100);
pub const _M_X64 = @as(c_int, 100);
pub const @"_" = @as(c_int, 1);
pub const __MINGW_USE_UNDERSCORE_PREFIX = @as(c_int, 0);
pub inline fn __MINGW_USYMBOL(sym: anytype) @TypeOf(sym) {
    return sym;
}
pub inline fn __MINGW_ASM_CALL(func: anytype) @TypeOf(__asm__(__MINGW64_STRINGIFY(__MINGW_USYMBOL(func)))) {
    return __asm__(__MINGW64_STRINGIFY(__MINGW_USYMBOL(func)));
}
pub inline fn __MINGW_ASM_CRT_CALL(func: anytype) @TypeOf(__asm__(__STRINGIFY(func))) {
    return __asm__(__STRINGIFY(func));
}
pub const __MINGW_EXTENSION = __extension__;
pub const __C89_NAMELESS = __MINGW_EXTENSION;
pub const __GNU_EXTENSION = __MINGW_EXTENSION;
pub const __MINGW_HAVE_ANSI_C99_PRINTF = @as(c_int, 1);
pub const __MINGW_HAVE_WIDE_C99_PRINTF = @as(c_int, 1);
pub const __MINGW_HAVE_ANSI_C99_SCANF = @as(c_int, 1);
pub const __MINGW_HAVE_WIDE_C99_SCANF = @as(c_int, 1);
pub const __MINGW_GCC_VERSION = ((__GNUC__ * @as(c_int, 10000)) + (__GNUC_MINOR__ * @as(c_int, 100))) + __GNUC_PATCHLEVEL__;
pub inline fn __MINGW_GNUC_PREREQ(major: anytype, minor: anytype) @TypeOf((__GNUC__ > major) or ((__GNUC__ == major) and (__GNUC_MINOR__ >= minor))) {
    return (__GNUC__ > major) or ((__GNUC__ == major) and (__GNUC_MINOR__ >= minor));
}
pub inline fn __MINGW_MSC_PREREQ(major: anytype, minor: anytype) @TypeOf(@as(c_int, 0)) {
    _ = major;
    _ = minor;
    return @as(c_int, 0);
}
pub const __MINGW_SEC_WARN_STR = "This function or variable may be unsafe, use _CRT_SECURE_NO_WARNINGS to disable deprecation";
pub const __MINGW_MSVC2005_DEPREC_STR = "This POSIX function is deprecated beginning in Visual C++ 2005, use _CRT_NONSTDC_NO_DEPRECATE to disable deprecation";
pub const __MINGW_ATTRIB_DEPRECATED_SEC_WARN = __MINGW_ATTRIB_DEPRECATED_STR(__MINGW_SEC_WARN_STR);
pub inline fn __MINGW_MS_PRINTF(__format: anytype, __args: anytype) @TypeOf(__attribute__(__format__(ms_printf, __format, __args))) {
    return __attribute__(__format__(ms_printf, __format, __args));
}
pub inline fn __MINGW_MS_SCANF(__format: anytype, __args: anytype) @TypeOf(__attribute__(__format__(ms_scanf, __format, __args))) {
    return __attribute__(__format__(ms_scanf, __format, __args));
}
pub inline fn __MINGW_GNU_PRINTF(__format: anytype, __args: anytype) @TypeOf(__attribute__(__format__(gnu_printf, __format, __args))) {
    return __attribute__(__format__(gnu_printf, __format, __args));
}
pub inline fn __MINGW_GNU_SCANF(__format: anytype, __args: anytype) @TypeOf(__attribute__(__format__(gnu_scanf, __format, __args))) {
    return __attribute__(__format__(gnu_scanf, __format, __args));
}
pub const __mingw_static_ovr = __mingw_ovr;
pub const __MINGW_FORTIFY_LEVEL = @as(c_int, 0);
pub const __mingw_bos_ovr = __mingw_ovr;
pub const __MINGW_FORTIFY_VA_ARG = @as(c_int, 0);
pub const _CRT_SECURE_CPP_OVERLOAD_SECURE_NAMES = @as(c_int, 0);
pub const _CRT_SECURE_CPP_OVERLOAD_SECURE_NAMES_MEMORY = @as(c_int, 0);
pub const _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES = @as(c_int, 0);
pub const _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES_COUNT = @as(c_int, 0);
pub const _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES_MEMORY = @as(c_int, 0);
pub const __LONG32 = c_long;
pub const __USE_CRTIMP = @as(c_int, 1);
pub const _CRTIMP = __attribute__(__dllimport__);
pub const USE___UUIDOF = @as(c_int, 0);
pub const _inline = __inline;
pub inline fn __UNUSED_PARAM(x: anytype) @TypeOf(x ++ __attribute__(__unused__)) {
    return x ++ __attribute__(__unused__);
}
pub const __restrict_arr = __restrict;
pub const __MINGW_ATTRIB_NORETURN = __attribute__(__noreturn__);
pub const __MINGW_ATTRIB_CONST = __attribute__(__const__);
pub const __MINGW_ATTRIB_MALLOC = __attribute__(__malloc__);
pub const __MINGW_ATTRIB_PURE = __attribute__(__pure__);
pub inline fn __MINGW_ATTRIB_NONNULL(arg: anytype) @TypeOf(__attribute__(__nonnull__(arg))) {
    return __attribute__(__nonnull__(arg));
}
pub const __MINGW_ATTRIB_UNUSED = __attribute__(__unused__);
pub const __MINGW_ATTRIB_USED = __attribute__(__used__);
pub const __MINGW_ATTRIB_DEPRECATED = __attribute__(__deprecated__);
pub inline fn __MINGW_ATTRIB_DEPRECATED_MSG(x: anytype) @TypeOf(__attribute__(__deprecated__(x))) {
    return __attribute__(__deprecated__(x));
}
pub const __MINGW_NOTHROW = __attribute__(__nothrow__);
pub const __MSVCRT_VERSION__ = @as(c_int, 0x700);
pub const _WIN32_WINNT = @as(c_int, 0x0603);
pub const __int8 = u8;
pub const __int16 = c_short;
pub const __int32 = c_int;
pub const __int64 = c_longlong;
pub const MINGW_HAS_SECURE_API = @as(c_int, 1);
pub const __STDC_SECURE_LIB__ = @as(c_long, 200411);
pub const __GOT_SECURE_LIB__ = __STDC_SECURE_LIB__;
pub const MINGW_HAS_DDK_H = @as(c_int, 1);
pub const _CRT_PACKING = @as(c_int, 8);
pub inline fn _ADDRESSOF(v: anytype) @TypeOf(&v) {
    return &v;
}
pub inline fn _CRT_STRINGIZE(_Value: anytype) @TypeOf(__CRT_STRINGIZE(_Value)) {
    return __CRT_STRINGIZE(_Value);
}
pub inline fn _CRT_WIDE(_String: anytype) @TypeOf(__CRT_WIDE(_String)) {
    return __CRT_WIDE(_String);
}
pub const _CRTIMP_NOIA64 = _CRTIMP;
pub const _CRTIMP2 = _CRTIMP;
pub const _CRTIMP_ALTERNATIVE = _CRTIMP;
pub const _MRTIMP2 = _CRTIMP;
pub const _MCRTIMP = _CRTIMP;
pub const _CRTIMP_PURE = _CRTIMP;
pub const _SECURECRT_FILL_BUFFER_PATTERN = @as(c_int, 0xFD);
pub inline fn _CRT_DEPRECATE_TEXT(_Text: anytype) @TypeOf(__declspec(deprecated)) {
    _ = _Text;
    return __declspec(deprecated);
}
pub const UNALIGNED = __unaligned;
pub inline fn _CRT_ALIGN(x: anytype) @TypeOf(__attribute__(__aligned__(x))) {
    return __attribute__(__aligned__(x));
}
pub const __CRTDECL = __cdecl;
pub const _ARGMAX = @as(c_int, 100);
pub const _TRUNCATE = @import("std").zig.c_translation.cast(usize, -@as(c_int, 1));
pub inline fn _CRT_UNUSED(x: anytype) c_void {
    return @import("std").zig.c_translation.cast(c_void, x);
}
pub const __USE_MINGW_ANSI_STDIO = @as(c_int, 1);
pub const _CRT_glob = _dowildcard;
pub const _ANONYMOUS_UNION = __MINGW_EXTENSION;
pub const _ANONYMOUS_STRUCT = __MINGW_EXTENSION;
pub const __MINGW_DEBUGBREAK_IMPL = !(__has_builtin(__debugbreak) != 0);
pub const _CRT_SECURE_CPP_NOTHROW = throw();
pub const PATH_MAX = @as(c_int, 260);
pub const CHAR_BIT = @as(c_int, 8);
pub const SCHAR_MIN = -@as(c_int, 128);
pub const SCHAR_MAX = @as(c_int, 127);
pub const UCHAR_MAX = @as(c_int, 0xff);
pub const CHAR_MIN = SCHAR_MIN;
pub const CHAR_MAX = SCHAR_MAX;
pub const MB_LEN_MAX = @as(c_int, 5);
pub const SHRT_MIN = -@import("std").zig.c_translation.promoteIntLiteral(c_int, 32768, .decimal);
pub const SHRT_MAX = @as(c_int, 32767);
pub const USHRT_MAX = @as(c_uint, 0xffff);
pub const INT_MIN = -@import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal) - @as(c_int, 1);
pub const INT_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const UINT_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 0xffffffff, .hexadecimal);
pub const LONG_MIN = -@as(c_long, 2147483647) - @as(c_int, 1);
pub const LONG_MAX = @as(c_long, 2147483647);
pub const ULONG_MAX = @as(c_ulong, 0xffffffff);
pub const LLONG_MAX = @as(c_longlong, 9223372036854775807);
pub const LLONG_MIN = -@as(c_longlong, 9223372036854775807) - @as(c_int, 1);
pub const ULLONG_MAX = @as(c_ulonglong, 0xffffffffffffffff);
pub const _I8_MIN = -@as(c_int, 127) - @as(c_int, 1);
pub const _I8_MAX = @as(c_int, 127);
pub const _UI8_MAX = @as(c_uint, 0xff);
pub const _I16_MIN = -@as(c_int, 32767) - @as(c_int, 1);
pub const _I16_MAX = @as(c_int, 32767);
pub const _UI16_MAX = @as(c_uint, 0xffff);
pub const _I32_MIN = -@import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal) - @as(c_int, 1);
pub const _I32_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const _UI32_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 0xffffffff, .hexadecimal);
pub const LONG_LONG_MAX = @as(c_longlong, 9223372036854775807);
pub const LONG_LONG_MIN = -LONG_LONG_MAX - @as(c_int, 1);
pub const ULONG_LONG_MAX = (@as(c_ulonglong, 2) * LONG_LONG_MAX) + @as(c_ulonglong, 1);
pub const _I64_MIN = -@as(c_longlong, 9223372036854775807) - @as(c_int, 1);
pub const _I64_MAX = @as(c_longlong, 9223372036854775807);
pub const _UI64_MAX = @as(c_ulonglong, 0xffffffffffffffff);
pub const SIZE_MAX = _UI64_MAX;
pub const SSIZE_MAX = _I64_MAX;
pub const __USE_MINGW_STRTOX = @as(c_int, 1);
pub const _SECIMP = __declspec(dllimport);
pub const NULL = @import("std").zig.c_translation.cast(?*c_void, @as(c_int, 0));
pub const EXIT_SUCCESS = @as(c_int, 0);
pub const EXIT_FAILURE = @as(c_int, 1);
pub const onexit_t = _onexit_t;
pub inline fn _PTR_LD(x: anytype) [*c]u8 {
    return @import("std").zig.c_translation.cast([*c]u8, &x.*.ld);
}
pub const RAND_MAX = @as(c_int, 0x7fff);
pub const MB_CUR_MAX = ___mb_cur_max_func();
pub const __mb_cur_max = ___mb_cur_max_func();
pub inline fn __max(a: anytype, b: anytype) @TypeOf(if (a > b) a else b) {
    return if (a > b) a else b;
}
pub inline fn __min(a: anytype, b: anytype) @TypeOf(if (a < b) a else b) {
    return if (a < b) a else b;
}
pub const _MAX_PATH = @as(c_int, 260);
pub const _MAX_DRIVE = @as(c_int, 3);
pub const _MAX_DIR = @as(c_int, 256);
pub const _MAX_FNAME = @as(c_int, 256);
pub const _MAX_EXT = @as(c_int, 256);
pub const _OUT_TO_DEFAULT = @as(c_int, 0);
pub const _OUT_TO_STDERR = @as(c_int, 1);
pub const _OUT_TO_MSGBOX = @as(c_int, 2);
pub const _REPORT_ERRMODE = @as(c_int, 3);
pub const _WRITE_ABORT_MSG = @as(c_int, 0x1);
pub const _CALL_REPORTFAULT = @as(c_int, 0x2);
pub const _MAX_ENV = @as(c_int, 32767);
pub const errno = _errno().*;
pub const _doserrno = __doserrno().*;
pub const _fmode = __p__fmode().*;
pub const __argc = __MINGW_IMP_SYMBOL(__argc).*;
pub const __argv = __p___argv().*;
pub const __wargv = __MINGW_IMP_SYMBOL(__wargv).*;
pub const _environ = __MINGW_IMP_SYMBOL(_environ).*;
pub const _wenviron = __MINGW_IMP_SYMBOL(_wenviron).*;
pub const _pgmptr = __MINGW_IMP_SYMBOL(_pgmptr).*;
pub const _wpgmptr = __MINGW_IMP_SYMBOL(_wpgmptr).*;
pub const _osplatform = __MINGW_IMP_SYMBOL(_osplatform).*;
pub const _osver = __MINGW_IMP_SYMBOL(_osver).*;
pub const _winver = __MINGW_IMP_SYMBOL(_winver).*;
pub const _winmajor = __MINGW_IMP_SYMBOL(_winmajor).*;
pub const _winminor = __MINGW_IMP_SYMBOL(_winminor).*;
pub const _CVTBUFSIZE = @as(c_int, 309) + @as(c_int, 40);
pub const sys_errlist = _sys_errlist;
pub const sys_nerr = _sys_nerr;
pub const environ = _environ;
pub const _HEAP_MAXREQ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0xFFFFFFFFFFFFFFE0, .hexadecimal);
pub const _HEAPEMPTY = -@as(c_int, 1);
pub const _HEAPOK = -@as(c_int, 2);
pub const _HEAPBADBEGIN = -@as(c_int, 3);
pub const _HEAPBADNODE = -@as(c_int, 4);
pub const _HEAPEND = -@as(c_int, 5);
pub const _HEAPBADPTR = -@as(c_int, 6);
pub const _FREEENTRY = @as(c_int, 0);
pub const _USEDENTRY = @as(c_int, 1);
pub const _MAX_WAIT_MALLOC_CRT = @import("std").zig.c_translation.promoteIntLiteral(c_int, 60000, .decimal);
pub const _ALLOCA_S_THRESHOLD = @as(c_int, 1024);
pub const _ALLOCA_S_STACK_MARKER = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0xCCCC, .hexadecimal);
pub const _ALLOCA_S_HEAP_MARKER = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0xDDDD, .hexadecimal);
pub const _ALLOCA_S_MARKER_SIZE = @as(c_int, 16);
pub inline fn _malloca(size: anytype) @TypeOf(if ((size + _ALLOCA_S_MARKER_SIZE) <= _ALLOCA_S_THRESHOLD) _MarkAllocaS(_alloca(size + _ALLOCA_S_MARKER_SIZE), _ALLOCA_S_STACK_MARKER) else _MarkAllocaS(malloc(size + _ALLOCA_S_MARKER_SIZE), _ALLOCA_S_HEAP_MARKER)) {
    return if ((size + _ALLOCA_S_MARKER_SIZE) <= _ALLOCA_S_THRESHOLD) _MarkAllocaS(_alloca(size + _ALLOCA_S_MARKER_SIZE), _ALLOCA_S_STACK_MARKER) else _MarkAllocaS(malloc(size + _ALLOCA_S_MARKER_SIZE), _ALLOCA_S_HEAP_MARKER);
}
pub inline fn SPRITEBATCH_MALLOC(size: anytype, ctx: anytype) @TypeOf(malloc(size)) {
    _ = ctx;
    return malloc(size);
}
pub inline fn SPRITEBATCH_FREE(ptr: anytype, ctx: anytype) @TypeOf(free(ptr)) {
    _ = ctx;
    return free(ptr);
}
pub const _NLSCMPERROR = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const _WConst_return = _CONST_RETURN;
pub const wcswcs = wcsstr;
pub inline fn SPRITEBATCH_MEMCPY(dst: anytype, src: anytype, n: anytype) @TypeOf(memcpy(dst, src, n)) {
    return memcpy(dst, src, n);
}
pub inline fn SPRITEBATCH_MEMSET(ptr: anytype, val: anytype, n: anytype) @TypeOf(memset(ptr, val, n)) {
    return memset(ptr, val, n);
}
pub inline fn SPRITEBATCH_MEMMOVE(dst: anytype, src: anytype, n: anytype) @TypeOf(memmove(dst, src, n)) {
    return memmove(dst, src, n);
}
pub inline fn assert(_Expression: anytype) c_void {
    _ = _Expression;
    return @import("std").zig.c_translation.cast(c_void, @as(c_int, 0));
}
pub inline fn SPRITEBATCH_ASSERT(condition: anytype) @TypeOf(assert(condition)) {
    return assert(condition);
}
pub const SPRITEBATCH_ATLAS_FLIP_Y_AXIS_FOR_UV = @as(c_int, 1);
pub const SPRITEBATCH_LONELY_FLIP_Y_AXIS_FOR_UV = @as(c_int, 1);
pub const SPRITEBATCH_ATLAS_EMPTY_COLOR = @as(c_int, 0x00000000);
pub inline fn HASHTABLE_MEMSET(ptr: anytype, val: anytype, n: anytype) @TypeOf(SPRITEBATCH_MEMSET(ptr, val, n)) {
    return SPRITEBATCH_MEMSET(ptr, val, n);
}
pub inline fn HASHTABLE_MEMCPY(dst: anytype, src: anytype, n: anytype) @TypeOf(SPRITEBATCH_MEMCPY(dst, src, n)) {
    return SPRITEBATCH_MEMCPY(dst, src, n);
}
pub inline fn HASHTABLE_MALLOC(ctx: anytype, size: anytype) @TypeOf(SPRITEBATCH_MALLOC(size, ctx)) {
    return SPRITEBATCH_MALLOC(size, ctx);
}
pub inline fn HASHTABLE_FREE(ctx: anytype, ptr: anytype) @TypeOf(SPRITEBATCH_FREE(ptr, ctx)) {
    return SPRITEBATCH_FREE(ptr, ctx);
}
pub const HASHTABLE_SIZE_T = usize;
pub inline fn HASHTABLE_ASSERT(x: anytype) @TypeOf(assert(x)) {
    return assert(x);
}
pub const hashtable_internal_slot_t = struct_hashtable_internal_slot_t;
pub const tagLC_ID = struct_tagLC_ID;
pub const lconv = struct_lconv;
pub const __lc_time_data = struct___lc_time_data;
pub const threadlocaleinfostruct = struct_threadlocaleinfostruct;
pub const threadmbcinfostruct = struct_threadmbcinfostruct;
pub const localeinfo_struct = struct_localeinfo_struct;
pub const _div_t = struct__div_t;
pub const _ldiv_t = struct__ldiv_t;
pub const _heapinfo = struct__heapinfo;
