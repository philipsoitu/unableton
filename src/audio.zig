const std = @import("std");
const Track = @import("track.zig").Track;

pub const Audio = struct {
    allocator: std.mem.Allocator,
    frequency: u32,
    duration: u32,
    tracks: std.ArrayList(*Track),

    pub fn init(allocator: std.mem.Allocator, frequency: u32, duration: u32) !@This() {
        return @This(){
            .allocator = allocator,
            .frequency = frequency,
            .duration = duration,
            .tracks = .empty,
        };
    }

    pub fn deinit(self: *@This()) void {
        self.tracks.deinit(self.allocator);
    }

    pub fn addTrack(self: *@This(), track: *Track) !void {
        try self.tracks.append(self.allocator, track);
    }

    pub fn saveWAV(self: *@This(), filename: []const u8) !void {
        const file = try std.fs.cwd().createFile(
            filename,
            .{ .read = true },
        );
        defer file.close();

        const num_samples = self.frequency * self.duration;
        const file_size = num_samples * @sizeOf(u16) + 44;

        // master riff
        _ = try file.write("RIFF");
        try file_write_int(file, u32, file_size);
        _ = try file.write("WAVE");

        // data format
        _ = try file.write("fmt ");
        try file_write_int(file, u32, 16);
        try file_write_int(file, u16, 1);
        try file_write_int(file, u16, 1);
        try file_write_int(file, u32, self.frequency);
        try file_write_int(file, u32, self.frequency * @sizeOf(u16));
        try file_write_int(file, u16, @sizeOf(u16));
        try file_write_int(file, u16, @sizeOf(u16) * 8);

        // try file_write_int(file);
        _ = try file.write("data");
        try file_write_int(file, u32, num_samples * @sizeOf(u16));

        for (0..num_samples) |i| {
            const t = @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(self.frequency));
            const y = @sin(t * 400.0 * 2 * 3.141592);
            const sample = @as(i16, @intFromFloat(y * std.math.maxInt(i16)));
            std.debug.print("{}: {}\n", .{ t, sample });
            try file_write_int(file, i16, sample);
        }
    }
};

fn file_write_int(file: std.fs.File, comptime T: type, num: T) !void {
    var buf: [@sizeOf(T)]u8 = undefined;
    std.mem.writeInt(T, &buf, num, .little);
    _ = try file.write(&buf);
}
