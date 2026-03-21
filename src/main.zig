const std = @import("std");
const AudioProject = @import("audio_project.zig").AudioProject;
const Track = @import("track.zig").Track;
const makeSineTrack = @import("track.zig").makeSineTrack;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var audio = try AudioProject.init(44100, 3);
    defer audio.deinit(allocator);

    var track0 = try makeSineTrack(
        allocator,
        0,
        3 * 44100,
        44100,
        400.0,
    );
    defer track0.deinit(allocator);
    try audio.addTrack(allocator, &track0);

    var track1 = try makeSineTrack(
        allocator,
        44100,
        2 * 44100,
        44100,
        500.0,
    );
    defer track1.deinit(allocator);
    try audio.addTrack(allocator, &track1);

    try audio.saveWAV(allocator, "out/test.wav");
}
