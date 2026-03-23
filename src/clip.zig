const std = @import("std");
const AudioBuffer = @import("audio_buffer.zig").AudioBuffer;

pub const Clip = struct {
    sample_start: u32,
    track_start: u32,
    duration: u32,
    sample_data: *AudioBuffer,
};
