const std = @import("std");
const AudioProject = @import("audio_project.zig").AudioProject;
const AudioBuffer = @import("audio_buffer.zig").AudioBuffer;
const Track = @import("track.zig").Track;
const Clip = @import("clip.zig").Clip;
const makeSineClip = @import("clip.zig").makeSineClip;

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var audio = try AudioProject.init(44100, 3);
    defer audio.deinit(allocator);

    var track0 = Track.init();
    defer track0.deinit(allocator);
    try audio.addTrack(allocator, &track0);

    var buf = try AudioBuffer.initFromWav(allocator, "out/car-horn.wav");
    defer buf.deinit(allocator);

    var buf1 = try AudioBuffer.initFromWav(allocator, "out/test.wav");
    defer buf1.deinit(allocator);

    var clip = Clip{
        .sample_start = 44100 * 1,
        .track_start = 44100 * 2,
        .duration = 44100 * 1,
        .sample_data = &buf,
    };

    var clip1 = Clip{
        .sample_start = 44100 * 0,
        .track_start = 44100 * 0,
        .duration = 44100 * 3,
        .sample_data = &buf1,
    };

    try track0.addClip(allocator, &clip);
    try track0.addClip(allocator, &clip1);

    try audio.saveWAV(allocator, "out/test2.wav");
}
