const std = @import("std");
const print = @import("std").debug.print;

pub const AudioBufferGroup = struct {
    samples: []AudioBuffer,
    channels: u16,
    sample_rate: u32,

    pub fn initFromWAV(allocator: std.mem.Allocator, filename: []const u8) !@This() {
        const file = try std.fs.cwd().readFileAlloc(
            allocator,
            filename,
            std.math.maxInt(u32), // max 4GB
        );
        defer allocator.free(file);

        return error.NotImplemented;
    }
};

pub const AudioBuffer = struct {
    data: []f32,
    channel_num: u16,
};
