const std = @import("std");
const AudioProject = @import("audio_project.zig").AudioProject;
const Clip = @import("clip.zig").Clip;
const makeSineClip = @import("clip.zig").makeSineClip;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var audio = try AudioProject.init(44100, 3);
    defer audio.deinit(allocator);

    var track0 = try makeSineClip(
        allocator,
        0,
        3 * 44100,
        44100,
        400.0,
    );
    defer track0.deinit(allocator);
    try audio.addTrack(allocator, &track0);

    var track1 = try makeSineClip(
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
