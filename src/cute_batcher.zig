const std = @import("std");

const Sprite = struct {
	// `image_id` must be a unique identifier for the image a sprite references.
	// You must set this value!
    image_id: u64,
	// The `texture_id` can set to zero `spritebatch_push`. This value will be overwritten
	// with a valid texture id of a generated atlas before batches are reported back to you.
    texture_id: u64,       
    w: i32,  h: i32,      // width and height of this sprite in pixels
    x: f32,  y: f32,      // x and y position
    sx: f32, sy: f32,     // scale on x and y axis
    c: f32,  s: f32,      // cosine and sine (represents cos(angle) and sin(angle))
    minx: f32, miny: f32, // u coordinate -- This value is for internal use only -- do not set.
    maxx: f32, maxy: f32, // v coordinate -- This value is for internal use only -- do not set.
    sort_bits: u32,
};

const SpriteBatch = struct {
    pub fn init(sb: *SpriteBatch, config: *Config, udata: ?*c_void) i32 {

    }

    pub fn term(sb: *SpriteBatch) void {
        
    }

    // Pushes a sprite onto an internal buffer. Does no other logic.
    pub fn push(sb: *SpriteBatch, sprite: Sprite) i32 {

    }

    // Ensures the image associated with your unique `image_id` is loaded up into spritebatch. This
    // function pretends to draw a sprite referencing `image_id` but doesn't actually do any
    // drawing at all. Use this function as an optimization to pre-load images you know will be
    // drawn very soon, e.g. prefetch all ten images within a single animation just as it starts
    // playing.
    pub fn prefetch(sb: *SpriteBatch, image_id: u64, w: i32, h: i32) void {

    }

    // Increments internal timestamps on all textures, for use in `spritebatch_defrag`.
    pub fn tick(sb: *SpriteBatch) void {

    }

    // Sorts the internal sprites and flushes the buffer built by `spritebatch_push`. Will call
    // the `submit_batch_fn` function for each batch of sprites and return them as an array. Any `image_id`
    // within the `spritebatch_push` buffer that do not yet have a texture handle will request pixels
    // from the image via `get_pixels_fn` and request a texture handle via `generate_texture_handle_fn`.
    // Returns the number of batches created and submitted.
    pub fn flush(sb: *SpriteBatch) i32 {

    }

    // All textures created so far by `spritebatch_flush` will be considered as candidates for creating
    // new internal texture atlases. Internal texture atlases compress images together inside of one
    // texture to dramatically reduce draw calls. When an atlas is created, the most recently used `image_id`
    // instances are prioritized, to ensure atlases are filled with images all drawn at the same time.
    // As some textures cease to draw on screen, they "decay" over time. Once enough images in an atlas
    // decay, the atlas is removed, and any "live" images in the atlas are used to create new atlases.
    // Can be called every 1/N times `spritebatch_flush` is called.
    pub fn defrag(sb: *SpriteBatch) i32 {

    }

    // Sets all function pointers originally defined in the `config` struct when calling `spritebatch_init`.
    // Useful if DLL's are reloaded, or swapped, etc.
    pub fn resetFunctionPtrs(sb: *SpriteBatch) void {

    }

    // Initializes a set of good default paramaters. The users must still set
    // the four callbacks inside of `config`.
    pub fn setDefaultConfig(config: *Config) void {

    }
};

const Callbacks = struct {
	batch_callback: SubmitBatchFn,
	get_pixels_callback: GetPixelsFn,
	generate_texture_callback: GenerateTextureHandleFn,
	delete_texture_callback: DestroyTextureHandleFn,
	sprites_sorter_callback: ?SpritesSorterFn,
};

const Config = struct {
	pixel_stride: i32,
	atlas_width_in_pixels: i32,
	atlas_height_in_pixels: i32,
	atlas_use_border_pixels: i32,
	ticks_to_decay_texture: i32,         // number of ticks it takes for a texture handle to be destroyed via `destroy_texture_handle_fn`
	lonely_buffer_count_till_flush: i32, // Number of unique textures allowed to persist that are not a part of an atlas yet, each one allowed is another draw call.
	                                     // These are called "lonely textures", since they don't belong to any atlas yet. Set this to 0 if you want all textures to be
	                                     // immediately put into atlases. Setting a higher number, like 64, will buffer up 64 unique textures (which means up to an
	                                     // additional 64 draw calls) before flushing them into atlases. Too low of a lonely buffer count combined with a low tick
	                                     // to decay rate will cause performance problems where atlases are constantly created and immedately destroyed -- you have
	                                     // been warned! Use `SPRITEBATCH_LOG` to gain some insight on what's going on inside the spritebatch when tuning these settings.
	ratio_to_decay_atlas: f32,           // from 0 to 1, once ratio is less than `ratio_to_decay_atlas`, flush active textures in atlas to lonely buffer
	ratio_to_merge_atlases: f32,         // from 0 to 0.5, attempts to merge atlases with some ratio of empty space
    callbacks: Callbacks,
	allocator: *std.mem.Allocator,
};

const SpriteInternal = struct {
    image_id: u64,
    sort_bits: i32,
    w: i32, h: i32,
    x: f32, y: f32,
    sx: f32, sy: f32,
    c: f32, s: f32
};

const TextureInternal = struct {
    timestamp: i32,
    w: i32, h: i32,
	minx: f32, miny: f32,
	maxx: f32, maxy: f32,
    image_id: u64,
};

// Sprite batches are submit via synchronous callback back to the user. This function is called
// from inside `spritebatch_flush`. Each time `submit_batch_fn` is called an array of sprites
// is handed to the user. The sprites are intended to be further sorted by the user as desired
// (for example, additional sorting based on depth). `w` and `h` are the width/height, respectively,
// of the texture the batch of sprites resides upon. w/h can be useful for knowing texture dim-
// ensions, which is needed to know texel size or other measurements.
const SubmitBatchFn = fn(sprites: *Sprite, count: i32, texture_w: i32, texture_h: i32, udate: ?*c_void) void;

// cute_spritebatch.h needs to know how to get the pixels of an image, generate textures handles (for
// example glGenTextures for OpenGL), and destroy texture handles. These functions are all called
// from within the `spritebatch_defrag` function, and sometimes from `spritebatch_flush`.

// Called when the pixels are needed from the user. `image_id` maps to a unique image, and is *not*
// related to `texture_id` at all. `buffer` must be filled in with `bytes_to_fill` number of bytes.
// The user is assumed to know the width/height of the image, and can optionally verify that
// `bytes_to_fill` matches the user's w * h * stride for this particular image.
const GetPixelsFn = fn(image_id: u64, buffer: ?*c_void, bytes_to_fill: i32, udata: ?*c_void) void;

// Called with a new texture handle is needed. This will happen whenever a new atlas is created,
// and whenever new `image_id`s first appear to cute_spritebatch, and have yet to find their way
// into an appropriate atlas.
const GenerateTextureHandleFn = fn(pixels: ?*c_void, w: i32, h: i32, udata: ?*c_void) u64;

// Called whenever a texture handle is ready to be free'd up. This happens whenever a particular image
// or a particular atlas has not been used for a while, and is ready to be released.
const DestroyTextureHandleFn = fn(texture_id: u64, udata: ?*c_void) void;

// (Optional) If the user provides this callback, cute_spritebatch will call it to sort all of sprites before submit_batch 
// callback is called. The intention of sorting is to minimize the submit_batch calls. cute_spritebatch
// provides its own internal sorting function which will be used if the user does not provide this callback.
// 
// Example using std::sort (C++) - Please note the lambda needs to be a non-capturing one.
// 
//     config.sprites_sorter_callback = [](spritebatch_sprite_t* sprites, int count)
//     {
//         std::sort(sprites, sprites + count,
//         [](const spritebatch_sprite_t& a, const spritebatch_sprite_t& b) {
//             if (a.sort_bits < b.sort_bits) return true;
//             if (a.sort_bits == b.sort_bits && a.texture_id < b.texture_id) return true;
//             return false;
//         });
//     };
const SpritesSorterFn = fn(sprites: []Sprite) void;
