const std = @import("std");
const Audio = @import("audio.zig").Audio;
const Track = @import("track.zig").Track;
const makeSineTrack = @import("track.zig").makeSineTrack;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var audio = try Audio.init(allocator, 44100, 3);
    defer audio.deinit();

    var track0 = try makeSineTrack(
        allocator,
        0,
        3 * 44100,
        44100,
        400.0,
    );

    var track1 = try makeSineTrack(
        allocator,
        44100,
        2 * 44100,
        44100,
        500.0,
    );
    defer track0.deinit(allocator);
    defer track1.deinit(allocator);

    try audio.addTrack(&track0);
    try audio.addTrack(&track1);

    try audio.saveWAV(allocator, "out/test.wav");
}
