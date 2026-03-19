const std = @import("std");
const Audio = @import("audio.zig").Audio;
const Track = @import("track.zig").Track;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var audio = try Audio.init(allocator, 44100, 3);
    defer audio.deinit();

    try audio.saveWAV("out/test.wav");
}
