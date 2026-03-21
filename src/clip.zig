const std = @import("std");

pub const Clip = struct {
    start: u32,
    duration: u32,
    sample_rate: u32,
    sample_data: []const i16,

    pub fn deinit(self: *@This(), allocator: std.mem.Allocator) void {
        allocator.free(self.sample_data);
    }
};

pub fn makeSineClip(
    allocator: std.mem.Allocator,
    start: u32,
    duration: u32,
    sample_rate: u32,
    frequency: f32,
) !Clip {
    const sample_data = try allocator.alloc(i16, duration);

    for (0..duration) |i| {
        const t = @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(sample_rate));
        const y = @sin(t * frequency * 2.0 * std.math.pi);
        sample_data[i] = @as(i16, @intFromFloat(y * std.math.maxInt(i16)));
    }

    return Clip{
        .start = start,
        .duration = duration,
        .sample_rate = sample_rate,
        .sample_data = sample_data,
    };
}
