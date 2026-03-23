const std = @import("std");

const WavMetadata = struct {
    audio_format: u16,
    channels: u16,
    sample_rate: u32,
    byte_rate: u32,
    byte_per_block: u16,
    bits_per_sample: u16,
};

pub const AudioBuffer = struct {
    filepath: []const u8,
    metadata: WavMetadata,
    samples: []f32,

    pub fn initFromWav(allocator: std.mem.Allocator, filepath: []const u8) !@This() {
        const file = try std.fs.cwd().openFile(filepath, .{});
        defer file.close();

        const stat = try file.stat();
        const file_size: usize = @intCast(stat.size);

        const wav_bytes = try allocator.alloc(u8, file_size);
        defer allocator.free(wav_bytes);

        const read_len = try file.readAll(wav_bytes);
        if (read_len != file_size) return error.UnexpectedEof;

        if (wav_bytes.len < 44) return error.InvalidHeader;

        if (!std.mem.eql(u8, wav_bytes[0..4], "RIFF")) return error.NotRiff;
        // 4-8: filesize
        if (!std.mem.eql(u8, wav_bytes[8..12], "WAVE")) return error.NotWave;

        if (!std.mem.eql(u8, wav_bytes[12..16], "fmt ")) return error.NoFmt;
        // 16-20: bloc_size
        const audio_format = std.mem.readInt(u16, wav_bytes[20..22], .little);
        if (!(audio_format == 1 or audio_format == 3)) return error.InvalidAudioFormat;

        const channels = std.mem.readInt(u16, wav_bytes[22..24], .little);
        const sample_rate = std.mem.readInt(u32, wav_bytes[24..28], .little);
        const byte_rate = std.mem.readInt(u32, wav_bytes[28..32], .little);
        const byte_per_block = std.mem.readInt(u16, wav_bytes[32..34], .little);
        const bits_per_sample = std.mem.readInt(u16, wav_bytes[34..36], .little);

        const wav_metadata: WavMetadata = .{
            .audio_format = audio_format,
            .channels = channels,
            .sample_rate = sample_rate,
            .byte_rate = byte_rate,
            .byte_per_block = byte_per_block,
            .bits_per_sample = bits_per_sample,
        };

        if (!std.mem.eql(u8, wav_bytes[36..40], "data")) return error.NoData;
        const data_size = std.mem.readInt(u32, wav_bytes[40..44], .little);

        const samples = try allocator.alloc(f32, data_size);

        switch (audio_format) {
            1 => { //PCM
                switch (bits_per_sample) {
                    16 => {
                        for (0..data_size / 2) |i| {
                            const scale: f32 = @as(f32, @floatFromInt(std.math.maxInt(i16))) + 1.0;
                            const sample_bytes = wav_bytes[44 + i * 2 .. 44 + (i + 1) * 2];
                            const sample_int = std.mem.readInt(i16, sample_bytes[0..2], .little);
                            samples[i] = @as(f32, @floatFromInt(sample_int)) / scale;
                        }
                    },
                    24 => {
                        for (0..data_size / 3) |i| {
                            const scale: f32 = @as(f32, @floatFromInt(std.math.maxInt(i24))) + 1.0;
                            const sample_bytes = wav_bytes[44 + i * 3 .. 44 + (i + 1) * 3];
                            const sample_int = std.mem.readInt(i24, sample_bytes[0..3], .little);
                            samples[i] = @as(f32, @floatFromInt(sample_int)) / scale;
                        }
                    },
                    else => return error.UnsupportedBitsPerSample,
                }
            },
            3 => { // Float
                return error.NotImplemented;
            },
            else => unreachable,
        }

        return AudioBuffer{
            .filepath = filepath,
            .metadata = wav_metadata,
            .samples = samples,
        };
    }

    pub fn deinit(self: *const @This(), allocator: std.mem.Allocator) void {
        allocator.free(self.samples);
    }
};
