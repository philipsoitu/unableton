const std = @import("std");

const FREQUENCY = 44100;
const DURATION = 3;

fn file_write_int(file: std.fs.File, comptime T: type, num: T) !void {
    var buf: [@sizeOf(T)]u8 = undefined;
    std.mem.writeInt(T, &buf, num, .little);
    _ = try file.write(&buf);
}

pub fn main() !void {
    const file = try std.fs.cwd().createFile(
        "out/test.wav",
        .{ .read = true },
    );
    defer file.close();

    const num_samples = FREQUENCY * DURATION;
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
    try file_write_int(file, u32, FREQUENCY);
    try file_write_int(file, u32, FREQUENCY * @sizeOf(u16));
    try file_write_int(file, u16, @sizeOf(u16));
    try file_write_int(file, u16, @sizeOf(u16) * 8);

    // try file_write_int(file);
    _ = try file.write("data");
    try file_write_int(file, u32, num_samples * @sizeOf(u16));

    for (0..num_samples) |i| {
        const t = @as(f32, @floatFromInt(i)) / FREQUENCY;
        const y = @sin(t * 440.0 * 2 * 3.141592);
        const sample = @as(i16, @intFromFloat(y * std.math.maxInt(i16)));
        std.debug.print("{}: {}\n", .{ t, sample });
        try file_write_int(file, i16, sample);
    }
}
