const std = @import("std");
const Clip = @import("clip.zig").Clip;

pub const AudioProject = struct {
    frequency: u32,
    duration: u32,
    tracks: std.ArrayList(*Clip),

    pub fn init(frequency: u32, duration: u32) !@This() {
        return @This(){
            .frequency = frequency,
            .duration = duration,
            .tracks = .empty,
        };
    }

    pub fn deinit(self: *@This(), allocator: std.mem.Allocator) void {
        self.tracks.deinit(allocator);
    }

    pub fn addTrack(self: *@This(), allocator: std.mem.Allocator, track: *Clip) !void {
        try self.tracks.append(allocator, track);
    }

    pub fn saveWAV(self: *@This(), allocator: std.mem.Allocator, filename: []const u8) !void {
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

        // init SampleData
        const buff = try allocator.alloc(i16, num_samples);
        for (0..num_samples) |i| {
            buff[i] = 0;
        }

        for (self.tracks.items) |track| {
            for (0..track.sample_data.len) |i| {
                buff[i + track.start] = track.sample_data[i];
            }
        }

        for (0..num_samples) |i| {
            try file_write_int(file, i16, buff[i]);
        }
    }
};

fn file_write_int(file: std.fs.File, comptime T: type, num: T) !void {
    var buf: [@sizeOf(T)]u8 = undefined;
    std.mem.writeInt(T, &buf, num, .little);
    _ = try file.write(&buf);
}
